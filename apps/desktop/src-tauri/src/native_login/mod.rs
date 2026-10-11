//! NYLRA-owned primitives only. No backend HTTP adapter, identity rules or IPC.
//! The owner's proposed B1 return is IPv4 loopback /oidc-return with local S256.
use base64::{engine::general_purpose::URL_SAFE_NO_PAD, Engine};
use sha2::{Digest, Sha256};
use std::{
    io::{self, Read, Write},
    net::TcpListener,
    path::Path,
    ptr,
    time::{Duration, Instant},
};
use windows_sys::Win32::{Foundation::LocalFree, Security::Cryptography::*};

// Neither type is serializable or Debug: verifier and callback query never enter IPC/logs.
pub struct ReturnBinding {
    listener: TcpListener,
    verifier: String,
}
pub struct NativeReturn {
    pub callback: url::Url,
    verifier: String,
}
impl NativeReturn {
    pub fn verifier(&self) -> &str {
        &self.verifier
    }
}
fn random() -> io::Result<[u8; 32]> {
    let mut bytes = [0; 32];
    let status = unsafe {
        BCryptGenRandom(
            ptr::null_mut(),
            bytes.as_mut_ptr(),
            32,
            BCRYPT_USE_SYSTEM_PREFERRED_RNG,
        )
    };
    if status < 0 {
        return Err(io::Error::other("OS random generator failed"));
    }
    Ok(bytes)
}
impl ReturnBinding {
    pub fn new() -> io::Result<Self> {
        let listener = TcpListener::bind(("127.0.0.1", 0))?;
        listener.set_nonblocking(true)?;
        Ok(Self {
            listener,
            verifier: URL_SAFE_NO_PAD.encode(random()?),
        })
    }
    pub fn return_uri(&self) -> String {
        format!(
            "http://127.0.0.1:{}/oidc-return",
            self.listener.local_addr().expect("bound listener").port()
        )
    }
    pub fn challenge(&self) -> String {
        URL_SAFE_NO_PAD.encode(Sha256::digest(self.verifier.as_bytes()))
    }
    pub fn verifier(&self) -> &str {
        &self.verifier
    }
    pub fn wait(self, deadline: Duration) -> io::Result<NativeReturn> {
        self.wait_cancellable(deadline, &std::sync::atomic::AtomicBool::new(false))
    }
    pub fn wait_cancellable(
        self,
        deadline: Duration,
        cancelled: &std::sync::atomic::AtomicBool,
    ) -> io::Result<NativeReturn> {
        let start = Instant::now();
        let base = url::Url::parse(&self.return_uri()).expect("fixed native URI");
        while start.elapsed() < deadline {
            if cancelled.load(std::sync::atomic::Ordering::Relaxed) {
                return Err(io::Error::new(
                    io::ErrorKind::Interrupted,
                    "login cancelled",
                ));
            }
            let (mut stream, _) = match self.listener.accept() {
                Ok(v) => v,
                Err(e) if e.kind() == io::ErrorKind::WouldBlock => {
                    std::thread::sleep(Duration::from_millis(10));
                    continue;
                }
                Err(e) => return Err(e),
            };
            stream.set_read_timeout(Some(Duration::from_millis(250)))?;
            stream.set_write_timeout(Some(Duration::from_millis(250)))?;
            let mut header = Vec::new();
            let mut chunk = [0; 1024];
            while header.len() < 8192
                && !header.windows(4).any(|w| w == b"\r\n\r\n")
                && start.elapsed() < deadline
                && !cancelled.load(std::sync::atomic::Ordering::Relaxed)
            {
                match stream.read(&mut chunk) {
                    Ok(0) | Err(_) => break,
                    Ok(n) => header.extend_from_slice(&chunk[..n]),
                }
            }
            let callback = if start.elapsed() < deadline
                && !cancelled.load(std::sync::atomic::Ordering::Relaxed)
            {
                std::str::from_utf8(&header)
                    .ok()
                    .and_then(|h| parse_callback(h, &base))
            } else {
                None
            };
            let status = if callback.is_some() {
                "200 OK"
            } else {
                "400 Bad Request"
            };
            let _=stream.write_all(format!("HTTP/1.1 {status}\r\nContent-Length: 0\r\nCache-Control: no-store\r\nReferrer-Policy: no-referrer\r\nConnection: close\r\n\r\n").as_bytes());
            if let Some(callback) = callback {
                return Ok(NativeReturn {
                    callback,
                    verifier: self.verifier,
                });
            }
        }
        Err(io::Error::new(
            io::ErrorKind::TimedOut,
            "native return timed out",
        ))
    }
}
fn parse_callback(header: &str, base: &url::Url) -> Option<url::Url> {
    if header.len() >= 8192 || !header.ends_with("\r\n\r\n") {
        return None;
    }
    let mut lines = header.split("\r\n");
    let parts: Vec<_> = lines.next()?.split(' ').collect();
    if parts.len() != 3
        || parts[0] != "GET"
        || parts[2] != "HTTP/1.1"
        || !parts[1].starts_with("/oidc-return?")
        || parts[1].contains('#')
        || parts[1].contains('\\')
    {
        return None;
    }
    let hosts: Vec<_> = lines
        .filter_map(|l| l.split_once(':'))
        .filter(|(k, _)| k.eq_ignore_ascii_case("host"))
        .map(|(_, v)| v.trim())
        .collect();
    if hosts != [format!("127.0.0.1:{}", base.port()?).as_str()] {
        return None;
    }
    let u = base.join(parts[1]).ok()?;
    if u.origin() != base.origin()
        || u.path() != "/oidc-return"
        || u.query().is_none_or(str::is_empty)
    {
        return None;
    }
    Some(u)
}
fn crypt(value: &[u8], decrypt: bool) -> io::Result<Vec<u8>> {
    if value.is_empty() || value.len() > 65536 {
        return Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            "invalid protected material size",
        ));
    }
    let input = CRYPT_INTEGER_BLOB {
        cbData: value.len() as u32,
        pbData: value.as_ptr().cast_mut(),
    };
    let mut out = CRYPT_INTEGER_BLOB {
        cbData: 0,
        pbData: ptr::null_mut(),
    };
    let ok = unsafe {
        if decrypt {
            CryptUnprotectData(
                &input,
                ptr::null_mut(),
                ptr::null(),
                ptr::null(),
                ptr::null(),
                CRYPTPROTECT_UI_FORBIDDEN,
                &mut out,
            )
        } else {
            CryptProtectData(
                &input,
                ptr::null(),
                ptr::null(),
                ptr::null(),
                ptr::null(),
                CRYPTPROTECT_UI_FORBIDDEN,
                &mut out,
            )
        }
    };
    if ok == 0 {
        return Err(io::Error::last_os_error());
    }
    let bytes = unsafe { std::slice::from_raw_parts(out.pbData, out.cbData as usize) }.to_vec();
    unsafe { LocalFree(out.pbData.cast()) };
    Ok(bytes)
}
pub fn protect(value: &[u8]) -> io::Result<Vec<u8>> {
    crypt(value, false)
}
pub fn unprotect(value: &[u8]) -> io::Result<Vec<u8>> {
    crypt(value, true)
}
pub fn save_session(path: &Path, handle: &[u8]) -> io::Result<()> {
    use std::os::windows::ffi::OsStrExt;
    let encrypted = protect(handle)?;
    let parent = path
        .parent()
        .ok_or_else(|| io::Error::other("session path requires parent"))?;
    std::fs::create_dir_all(parent)?;
    let pending = parent.join(format!(
        ".session-{}.pending",
        URL_SAFE_NO_PAD.encode(random()?)
    ));
    let result = (|| {
        let mut f = std::fs::OpenOptions::new()
            .write(true)
            .create_new(true)
            .open(&pending)?;
        f.write_all(&encrypted)?;
        f.sync_all()?;
        drop(f);
        let from: Vec<_> = pending.as_os_str().encode_wide().chain(Some(0)).collect();
        let to: Vec<_> = path.as_os_str().encode_wide().chain(Some(0)).collect();
        let ok = unsafe {
            windows_sys::Win32::Storage::FileSystem::MoveFileExW(
                from.as_ptr(),
                to.as_ptr(),
                windows_sys::Win32::Storage::FileSystem::MOVEFILE_REPLACE_EXISTING
                    | windows_sys::Win32::Storage::FileSystem::MOVEFILE_WRITE_THROUGH,
            )
        };
        if ok == 0 {
            return Err(io::Error::last_os_error());
        }
        Ok(())
    })();
    if result.is_err() {
        let _ = std::fs::remove_file(&pending);
    }
    result
}
pub fn load_session(path: &Path) -> io::Result<Option<Vec<u8>>> {
    let f = match std::fs::File::open(path) {
        Ok(f) => f,
        Err(e) if e.kind() == io::ErrorKind::NotFound => return Ok(None),
        Err(e) => return Err(e),
    };
    let mut blob = Vec::new();
    f.take(65537).read_to_end(&mut blob)?;
    unprotect(&blob).map(Some)
}
pub fn clear_session(path: &Path) -> io::Result<()> {
    match std::fs::remove_file(path) {
        Err(e) if e.kind() == io::ErrorKind::NotFound => Ok(()),
        v => v,
    }
}

/// Caller supplies the reviewed HTTPS origin from backend configuration. Not IPC.
pub fn open_system_browser(url: &url::Url, reviewed_origin: &url::Url) -> io::Result<()> {
    if url.scheme() != "https"
        || url.origin() != reviewed_origin.origin()
        || !url.username().is_empty()
        || url.password().is_some()
        || url.fragment().is_some()
    {
        return Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            "unreviewed browser origin",
        ));
    }
    let value: Vec<u16> = url.as_str().encode_utf16().chain(Some(0)).collect();
    let verb: Vec<u16> = "open".encode_utf16().chain(Some(0)).collect();
    let result = unsafe {
        windows_sys::Win32::UI::Shell::ShellExecuteW(
            ptr::null_mut(),
            verb.as_ptr(),
            value.as_ptr(),
            ptr::null(),
            ptr::null(),
            1,
        )
    };
    if result as isize <= 32 {
        return Err(io::Error::other("system browser launch failed"));
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn client_binding_is_random_and_s256() {
        use base64::{engine::general_purpose::URL_SAFE_NO_PAD, Engine};
        use sha2::{Digest, Sha256};
        let a = ReturnBinding::new().unwrap();
        let b = ReturnBinding::new().unwrap();
        assert_eq!(a.verifier().len(), 43);
        assert_ne!(a.verifier(), b.verifier());
        assert_eq!(
            a.challenge(),
            URL_SAFE_NO_PAD.encode(Sha256::digest(a.verifier().as_bytes()))
        );
        let u = url::Url::parse(&a.return_uri()).unwrap();
        assert_eq!(u.host_str(), Some("127.0.0.1"));
        assert_eq!(u.path(), "/oidc-return");
        assert!(u.port().unwrap() > 0);
    }
    #[test]
    fn dpapi_roundtrip_and_tamper_refusal() {
        let plain = b"fixture-only-opaque-session";
        let mut blob = protect(plain).unwrap();
        assert!(!blob.windows(plain.len()).any(|w| w == plain));
        assert_eq!(unprotect(&blob).unwrap(), plain);
        let n = blob.len();
        assert!(n > 0);
        blob[n / 2] ^= 1;
        assert!(unprotect(&blob).is_err());
    }
    #[test]
    fn restart_load_then_local_logout_clears_material() {
        let path =
            std::env::temp_dir().join(format!("nylra-native-test-{}.bin", std::process::id()));
        clear_session(&path).unwrap();
        save_session(&path, b"fixture-only-opaque-session").unwrap();
        assert_eq!(
            load_session(&path).unwrap().unwrap(),
            b"fixture-only-opaque-session"
        );
        clear_session(&path).unwrap();
        assert!(load_session(&path).unwrap().is_none());
        clear_session(&path).unwrap();
    }
    #[test]
    fn loopback_ignores_foreign_host_and_returns_one_owned_callback() {
        use std::{
            io::{Read, Write},
            net::TcpStream,
            time::Duration,
        };
        let b = ReturnBinding::new().unwrap();
        let uri = b.return_uri();
        let u = url::Url::parse(&uri).unwrap();
        let port = u.port().unwrap();
        let peer = std::thread::spawn(move || {
            for host in [format!("evil.example:{port}"), format!("127.0.0.1:{port}")] {
                let mut stream = TcpStream::connect(("127.0.0.1", port)).unwrap();
                stream
                    .write_all(
                        format!("GET /oidc-return?ticket=fixture HTTP/1.1\r\nHost: {host}\r\n\r\n")
                            .as_bytes(),
                    )
                    .unwrap();
                let mut response = String::new();
                stream.read_to_string(&mut response).unwrap();
                assert!(response.contains(if host.starts_with("evil") {
                    "400"
                } else {
                    "200"
                }));
            }
        });
        let returned = b.wait(Duration::from_secs(5)).unwrap();
        assert_eq!(returned.callback.query(), Some("ticket=fixture"));
        peer.join().unwrap();
        assert!(TcpStream::connect(("127.0.0.1", port)).is_err());
    }
    #[test]
    fn cancellation_closes_native_listener() {
        let b = ReturnBinding::new().unwrap();
        let u = url::Url::parse(&b.return_uri()).unwrap();
        let result = b.wait_cancellable(
            Duration::from_secs(1),
            &std::sync::atomic::AtomicBool::new(true),
        );
        assert!(matches!(result,Err(e)if e.kind()==io::ErrorKind::Interrupted));
        assert!(std::net::TcpStream::connect(("127.0.0.1", u.port().unwrap())).is_err());
    }
    #[test]
    fn callback_rejects_wrong_method_path_fragment_and_duplicate_host() {
        let base = url::Url::parse("http://127.0.0.1:12345/oidc-return").unwrap();
        for header in ["POST /oidc-return?x=1 HTTP/1.1\r\nHost: 127.0.0.1:12345\r\n\r\n","GET /other?x=1 HTTP/1.1\r\nHost: 127.0.0.1:12345\r\n\r\n","GET /oidc-return?x=1#f HTTP/1.1\r\nHost: 127.0.0.1:12345\r\n\r\n","GET /oidc-return?x=1 HTTP/1.1\r\nHost: 127.0.0.1:12345\r\nHost: 127.0.0.1:12345\r\n\r\n"] {assert!(parse_callback(header,&base).is_none());}
    }
    #[test]
    fn browser_refuses_unreviewed_or_unsafe_url_before_launch() {
        let origin = url::Url::parse("https://backend.example").unwrap();
        for value in [
            "http://backend.example/login",
            "https://foreign.example/login",
            "https://user:pass@backend.example/login",
            "https://backend.example/login#fragment",
        ] {
            assert!(open_system_browser(&url::Url::parse(value).unwrap(), &origin).is_err());
        }
    }
    #[test]
    fn protected_store_replaces_material_and_refuses_corruption() {
        let dir = std::env::temp_dir().join(format!("nylra-replace-test-{}", std::process::id()));
        let path = dir.join("session.bin");
        save_session(&path, b"fixture-first").unwrap();
        save_session(&path, b"fixture-second").unwrap();
        assert_eq!(load_session(&path).unwrap().unwrap(), b"fixture-second");
        std::fs::write(&path, b"corrupt").unwrap();
        assert!(load_session(&path).is_err());
        clear_session(&path).unwrap();
        std::fs::remove_dir(&dir).unwrap();
    }
}
