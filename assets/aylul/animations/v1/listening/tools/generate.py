from pathlib import Path
import math
import shutil

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[6]
SOURCE_PATH = ROOT / "assets/aylul/states/v1/listening.png"
PACK_ROOT = ROOT / "assets/aylul/animations/v1/listening"
FRAMES_ROOT = PACK_ROOT / "frames"
MASKS_ROOT = PACK_ROOT / "derived/masks"
WIDTH = HEIGHT = 1254
FRAME_COUNT = 32


def smoothstep(value: float) -> float:
    return value * value * (3.0 - 2.0 * value)


def curve(frame: int, points: list[tuple[int, float]]) -> float:
    for index in range(len(points) - 1):
        left_frame, left_value = points[index]
        right_frame, right_value = points[index + 1]
        if left_frame <= frame <= right_frame:
            amount = (frame - left_frame) / (right_frame - left_frame)
            eased = smoothstep(amount)
            return left_value + (right_value - left_value) * eased
    return points[-1][1]


CURVES = {
    "body_angle_deg": [(0, 0.0), (3, 0.0), (8, -1.1), (12, 2.4), (17, 1.35), (22, -0.45), (27, 0.2), (31, 0.0)],
    "body_y_px": [(0, 0.0), (3, 0.0), (8, -4.0), (12, 3.0), (17, 0.0), (22, 1.5), (27, 0.0), (31, 0.0)],
    "eye_x_px": [(0, 0.0), (3, 0.0), (8, -7.0), (12, 18.0), (16, 12.0), (21, -3.5), (26, 1.5), (31, 0.0)],
    "eye_y_px": [(0, 0.0), (3, 0.0), (8, 2.0), (12, -8.0), (16, -5.0), (21, 2.0), (26, 0.0), (31, 0.0)],
    "eye_scale_y": [(0, 1.0), (3, 1.0), (8, 0.95), (12, 1.03), (16, 1.0), (21, 0.975), (26, 1.0), (31, 1.0)],
    "head_crystal_angle_deg": [(0, 0.0), (3, 0.0), (8, 3.6), (12, -3.2), (17, 1.6), (22, -0.7), (27, 0.25), (31, 0.0)],
    "head_crystal_y_px": [(0, 0.0), (3, 0.0), (8, 2.0), (12, -6.0), (17, -2.0), (22, 1.5), (27, 0.0), (31, 0.0)],
    "pendant_angle_deg": [(0, 0.0), (3, 0.0), (8, 6.0), (12, -9.0), (17, 7.0), (22, -3.5), (27, 1.0), (31, 0.0)],
    "head_glow_scale": [(0, 1.0), (6, 1.0), (12, 1.10), (17, 1.04), (23, 1.0), (31, 1.0)],
    "pendant_glow_scale": [(0, 1.0), (9, 1.0), (15, 1.08), (20, 1.03), (26, 1.0), (31, 1.0)],
}


def superellipse_mask(x_grid, y_grid, center_x, center_y, radius_x, radius_y, power=4.0):
    distance = (np.abs((x_grid - center_x) / radius_x) ** power) + (np.abs((y_grid - center_y) / radius_y) ** power)
    return np.exp(-2.6 * distance).astype(np.float32)


def rotate_inverse(x_coords, y_coords, pivot_x, pivot_y, angle_degrees, weight):
    angle = math.radians(angle_degrees)
    cosine = math.cos(angle)
    sine = math.sin(angle)
    delta_x = x_coords - pivot_x
    delta_y = y_coords - pivot_y
    rotated_x = pivot_x + cosine * delta_x + sine * delta_y
    rotated_y = pivot_y - sine * delta_x + cosine * delta_y
    return x_coords + (rotated_x - x_coords) * weight, y_coords + (rotated_y - y_coords) * weight


def bilinear_sample(channel, x_coords, y_coords):
    x0 = np.floor(x_coords).astype(np.int32)
    y0 = np.floor(y_coords).astype(np.int32)
    x1 = x0 + 1
    y1 = y0 + 1
    valid = (x0 >= 0) & (y0 >= 0) & (x1 < WIDTH) & (y1 < HEIGHT)
    x0c = np.clip(x0, 0, WIDTH - 1)
    x1c = np.clip(x1, 0, WIDTH - 1)
    y0c = np.clip(y0, 0, HEIGHT - 1)
    y1c = np.clip(y1, 0, HEIGHT - 1)
    x_fraction = x_coords - x0
    y_fraction = y_coords - y0
    top = channel[y0c, x0c] * (1.0 - x_fraction) + channel[y0c, x1c] * x_fraction
    bottom = channel[y1c, x0c] * (1.0 - x_fraction) + channel[y1c, x1c] * x_fraction
    result = top * (1.0 - y_fraction) + bottom * y_fraction
    return np.where(valid, result, 0.0).astype(np.float32)


def save_mask(mask, path):
    Image.fromarray(np.clip(np.rint(mask * 255.0), 0, 255).astype(np.uint8), mode="L").save(path)


def render_frame(source_rgba, source_alpha, source_premultiplied, x_grid, y_grid, eye_mask, head_mask, pendant_mask, frame):
    parameters = {name: curve(frame, points) for name, points in CURVES.items()}

    body_angle = math.radians(parameters["body_angle_deg"])
    cosine = math.cos(body_angle)
    sine = math.sin(body_angle)
    translated_x = x_grid - 627.0
    translated_y = y_grid - parameters["body_y_px"] - 1102.0
    source_x = 627.0 + cosine * translated_x + sine * translated_y
    source_y = 1102.0 - sine * translated_x + cosine * translated_y

    canonical_eye_mask = np.maximum(
        superellipse_mask(source_x, source_y, 522.0, 770.0, 112.0, 104.0),
        superellipse_mask(source_x, source_y, 728.0, 770.0, 112.0, 104.0),
    )
    eye_center_y = 770.0
    source_x -= parameters["eye_x_px"] * canonical_eye_mask
    source_y -= parameters["eye_y_px"] * canonical_eye_mask
    source_y += ((source_y - eye_center_y) / parameters["eye_scale_y"] - (source_y - eye_center_y)) * canonical_eye_mask

    canonical_head_mask = superellipse_mask(source_x, source_y, 627.0, 275.0, 175.0, 235.0)
    source_x, source_y = rotate_inverse(source_x, source_y, 627.0, 390.0, parameters["head_crystal_angle_deg"], canonical_head_mask)
    source_y -= parameters["head_crystal_y_px"] * canonical_head_mask

    canonical_pendant_mask = superellipse_mask(source_x, source_y, 820.0, 982.0, 105.0, 175.0)
    pendant_attachment = np.clip((source_y - 855.0) / 105.0, 0.0, 1.0)
    pendant_weight = canonical_pendant_mask * smoothstep(pendant_attachment)
    source_x, source_y = rotate_inverse(source_x, source_y, 817.0, 865.0, parameters["pendant_angle_deg"], pendant_weight)

    sampled_alpha = bilinear_sample(source_alpha, source_x, source_y)
    sampled_premultiplied = np.stack(
        [bilinear_sample(source_premultiplied[:, :, channel], source_x, source_y) for channel in range(3)],
        axis=2,
    )

    output_head_mask = bilinear_sample(head_mask, source_x, source_y)
    output_pendant_mask = bilinear_sample(pendant_mask, source_x, source_y)
    translucent = np.clip((0.90 - sampled_alpha) / 0.90, 0.0, 1.0)
    glow_multiplier = (
        1.0
        + (parameters["head_glow_scale"] - 1.0) * output_head_mask * translucent
        + (parameters["pendant_glow_scale"] - 1.0) * output_pendant_mask * translucent
    )
    adjusted_alpha = np.clip(sampled_alpha * glow_multiplier, 0.0, 1.0)
    alpha_ratio = np.divide(adjusted_alpha, sampled_alpha, out=np.zeros_like(adjusted_alpha), where=sampled_alpha > 1e-6)
    sampled_premultiplied *= alpha_ratio[:, :, None]

    output_rgb = np.divide(
        sampled_premultiplied,
        adjusted_alpha[:, :, None],
        out=np.zeros_like(sampled_premultiplied),
        where=adjusted_alpha[:, :, None] > 1e-6,
    )
    output = np.clip(np.rint(np.concatenate((output_rgb, adjusted_alpha[:, :, None]), axis=2) * 255.0), 0, 255).astype(np.uint8)
    output[:, :, :3][output[:, :, 3] == 0] = 0
    return output, parameters


def main():
    FRAMES_ROOT.mkdir(parents=True, exist_ok=True)
    MASKS_ROOT.mkdir(parents=True, exist_ok=True)
    source_image = Image.open(SOURCE_PATH).convert("RGBA")
    source_rgba = np.asarray(source_image, dtype=np.float32) / 255.0
    source_alpha = source_rgba[:, :, 3]
    source_premultiplied = source_rgba[:, :, :3] * source_alpha[:, :, None]
    y_grid, x_grid = np.mgrid[0:HEIGHT, 0:WIDTH].astype(np.float32)

    eye_mask = np.maximum(
        superellipse_mask(x_grid, y_grid, 522.0, 770.0, 112.0, 104.0),
        superellipse_mask(x_grid, y_grid, 728.0, 770.0, 112.0, 104.0),
    )
    head_mask = superellipse_mask(x_grid, y_grid, 627.0, 275.0, 175.0, 235.0)
    pendant_mask = superellipse_mask(x_grid, y_grid, 820.0, 982.0, 105.0, 175.0) * smoothstep(np.clip((y_grid - 855.0) / 105.0, 0.0, 1.0))
    save_mask(eye_mask, MASKS_ROOT / "eyes-influence.png")
    save_mask(head_mask, MASKS_ROOT / "head-crystal-influence.png")
    save_mask(pendant_mask, MASKS_ROOT / "pendant-influence.png")

    shutil.copyfile(SOURCE_PATH, PACK_ROOT / "still.png")
    shutil.copyfile(SOURCE_PATH, FRAMES_ROOT / "frame-000.png")
    for frame in range(1, FRAME_COUNT - 1):
        identity = all(abs(curve(frame, points) - (1.0 if name == "eye_scale_y" else 1.0 if name.endswith("glow_scale") else 0.0)) < 1e-9 for name, points in CURVES.items())
        if identity:
            shutil.copyfile(SOURCE_PATH, FRAMES_ROOT / f"frame-{frame:03d}.png")
            print(f"frame-{frame:03d}: canonical hold")
            continue
        output, parameters = render_frame(source_rgba, source_alpha, source_premultiplied, x_grid, y_grid, eye_mask, head_mask, pendant_mask, frame)
        Image.fromarray(output, mode="RGBA").save(FRAMES_ROOT / f"frame-{frame:03d}.png", optimize=True)
        print(
            f"frame-{frame:03d}: body={parameters['body_angle_deg']:+.3f}deg, "
            f"eyes=({parameters['eye_x_px']:+.2f},{parameters['eye_y_px']:+.2f}), "
            f"head={parameters['head_crystal_angle_deg']:+.2f}deg, "
            f"pendant={parameters['pendant_angle_deg']:+.2f}deg"
        )
    shutil.copyfile(SOURCE_PATH, FRAMES_ROOT / "frame-031.png")


if __name__ == "__main__":
    main()
