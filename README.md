# Bill Validator

Smart Flutter application that captures receipt/bill images, performs OCR (Google ML Kit), parses line items, and validates all monetary calculations (subtotal, tax, totals, tips, rounding) with confidence scoring and structured feedback.

## Features
* Image capture (camera) & gallery import
* Image preprocessing (crop, enhancement)
* OCR text extraction with positional data
* Regex-based semantic parsing & bill structure reconstruction
* Mathematical validation engine (line items, subtotal, tax, tip, total)
* Error classification with human‑readable messages
* Confidence scoring and corrected structure suggestions
* Cross‑platform: Android, iOS, Web (Chrome), Windows, macOS, Linux

## Tech Stack
| Layer | Tech |
|-------|------|
| UI | Flutter (Material 3) |
| State | Provider |
| OCR | google_mlkit_text_recognition |
| Image | image_picker, image_cropper, image |
| Logic | Custom parsing + regex + validation engine |

## Directory Structure (Key)
```
lib/
	screens/                # UI screens
	services/               # Image, OCR, validation, calculation
	models/                 # BillItem, BillStructure, ValidationResult, OCRResult
	utils/                  # Regex patterns, math helpers, constants
	widgets/                # Reusable UI components
```

## Quick Start
```powershell
git clone https://github.com/mira-mohamed2/miniature-rotary-phone.git
cd miniature-rotary-phone/bill_validator
flutter pub get
flutter run -d chrome   # or: flutter run -d windows / android / ios
```

## Running Tests
```powershell
flutter test
```

## Validation Flow
1. Capture/select image
2. Preprocess (resize, crop, enhance)
3. Run OCR → text elements + bounding boxes
4. Parse line items & financial totals
5. Compute validation & confidence
6. Present results + corrections

## Roadmap
- [ ] Multi-currency symbol & locale handling
- [ ] Discount / promotion parsing
- [ ] Multiple tax rate support per line item
- [ ] Export validation report (PDF/JSON)
- [ ] Offline model fallback
- [ ] Integration tests & golden tests

## CI
GitHub Actions workflow runs analyze, test, and a lightweight web build (`.github/workflows/ci.yml`).

## Contributing
1. Fork & clone
2. Create feature branch: `git checkout -b feat/your-feature`
3. Commit with conventional messages
4. Open PR with summary & screenshots (if UI)

## License
MIT – see `LICENSE`.

## Disclaimer
OCR accuracy varies by lighting, print quality, and layout. Always verify critical financial data manually.

