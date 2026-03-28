from __future__ import annotations

from pathlib import Path
from typing import Any

try:
    from PIL import Image, ImageEnhance, ImageOps
    import pytesseract
except ImportError:  # pragma: no cover - depends on local environment
    Image = None
    ImageEnhance = None
    ImageOps = None
    pytesseract = None


class OcrReader:
    def __init__(self) -> None:
        self._configure_tesseract_path()

    def is_available(self) -> bool:
        return pytesseract is not None and Image is not None

    def read_text(self, image: Any, config: str = "--oem 3 --psm 7") -> str:
        if pytesseract is None or Image is None:
            return ""

        for candidate in self._prepare_images(image):
            try:
                text = pytesseract.image_to_string(candidate, config=config)
            except pytesseract.TesseractNotFoundError:
                return ""

            cleaned = self._clean_text(text)
            if cleaned:
                return cleaned

        return ""

    def read_nick(self, image: Any) -> str:
        nick_configs = (
            "--oem 3 --psm 8 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-[]()",
            "--oem 3 --psm 13 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-[]()",
            "--oem 3 --psm 7 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-[]()",
        )

        for config in nick_configs:
            for candidate in self._prepare_nick_images(image):
                text = self._read_candidate(candidate, config)
                if text:
                    return text

        return ""

    def _prepare_images(self, image: Any) -> list[Any]:
        grayscale = image.convert("L")
        enlarged = grayscale.resize(
            (
                max(1, grayscale.width * 4),
                max(1, grayscale.height * 4),
            ),
            self._resample_filter(),
        )
        contrasted = ImageEnhance.Contrast(enlarged).enhance(2.5)
        autocontrasted = ImageOps.autocontrast(contrasted)

        binary_dark_text = autocontrasted.point(lambda value: 255 if value > 165 else 0)
        inverted = ImageOps.invert(autocontrasted)
        binary_light_text = inverted.point(lambda value: 255 if value > 165 else 0)

        return [
            image,
            autocontrasted,
            binary_dark_text,
            binary_light_text,
        ]

    def _prepare_nick_images(self, image: Any) -> list[Any]:
        cropped = image.crop((0, 0, image.width, max(1, image.height - 1)))
        grayscale = cropped.convert("L")
        bright_text_mask = self._extract_light_text(cropped)
        tight_mask = self._tight_crop(bright_text_mask, padding=2)
        enlarged = grayscale.resize(
            (
                max(1, grayscale.width * 8),
                max(1, grayscale.height * 8),
            ),
            self._resample_filter(),
        )
        enhanced = ImageOps.autocontrast(ImageEnhance.Contrast(enlarged).enhance(3.0))

        enlarged_mask = bright_text_mask.resize(
            (
                max(1, cropped.width * 8),
                max(1, cropped.height * 8),
            ),
            Image.Resampling.NEAREST if hasattr(Image, "Resampling") else Image.NEAREST,
        )
        enlarged_tight_mask = tight_mask.resize(
            (
                max(1, tight_mask.width * 12),
                max(1, tight_mask.height * 12),
            ),
            Image.Resampling.NEAREST if hasattr(Image, "Resampling") else Image.NEAREST,
        )

        return [
            enlarged_mask,
            enlarged_tight_mask,
            enhanced,
            enhanced.point(lambda value: 255 if value > 170 else 0),
        ]

    def _extract_light_text(self, image: Any) -> Any:
        mask = Image.new("L", image.size, 255)

        for x in range(image.width):
            for y in range(image.height):
                red, green, blue = image.getpixel((x, y))
                average = (red + green + blue) / 3
                channel_delta = max(red, green, blue) - min(red, green, blue)
                is_light_text = average > 165 and channel_delta < 55
                mask.putpixel((x, y), 0 if is_light_text else 255)

        return mask

    def _read_candidate(self, image: Any, config: str) -> str:
        try:
            text = pytesseract.image_to_string(image, config=config)
        except pytesseract.TesseractNotFoundError:
            return ""

        return self._clean_text(text)

    def _configure_tesseract_path(self) -> None:
        if pytesseract is None:
            return

        configured_path = getattr(pytesseract.pytesseract, "tesseract_cmd", "")
        if configured_path and Path(configured_path).exists():
            return

        candidates = (
            Path(r"C:/Program Files/Tesseract-OCR/tesseract.exe"),
            Path(r"C:/Program Files (x86)/Tesseract-OCR/tesseract.exe"),
            Path.home() / "AppData/Local/Programs/Tesseract-OCR/tesseract.exe",
        )

        for candidate in candidates:
            if candidate.exists():
                pytesseract.pytesseract.tesseract_cmd = str(candidate)
                return

    def _tight_crop(self, image: Any, padding: int = 0) -> Any:
        bbox = ImageOps.invert(image).getbbox()
        if bbox is None:
            return image

        left, top, right, bottom = bbox
        return image.crop(
            (
                max(0, left - padding),
                max(0, top - padding),
                min(image.width, right + padding),
                min(image.height, bottom + padding),
            )
        )

    def _resample_filter(self) -> int:
        if hasattr(Image, "Resampling"):
            return Image.Resampling.LANCZOS
        return Image.LANCZOS

    def _clean_text(self, text: str) -> str:
        return text.strip().replace("\n", "").replace("\r", "")
