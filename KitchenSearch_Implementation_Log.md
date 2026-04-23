# Kitchen Search - Nhật ký triển khai và xử lý

Tài liệu này tổng hợp lại toàn bộ quá trình triển khai để phục vụ thuyết trình, đối chiếu với BRD/SRS/AC và giải trình quyết định kỹ thuật.

## 1. Bối cảnh và mục tiêu
- Dự án: Kitchen Search (Món ăn theo nguyên liệu).
- Mục tiêu học phần: làm đúng SDLC (BRD -> SRS -> AC/Test -> Code -> Demo), không chỉ viết code.
- Dữ liệu: Mock API/JSON nội bộ để demo ổn định.

## 2. Tài liệu đã hoàn thiện
- BRD: KitchenSearch-BRD.md
- SRS: KitchenSearch-SRS.md
- AC + Test Cases: KitchenSearch-AC-TestCases.md
- Progress Tracker: KitchenSearch-Progress.md
- Plan tổng: KitchenSearch-Plan.md
- Mục lục tài liệu: KitchenSearch-Docs-Index.md

## 3. Timeline triển khai kỹ thuật

### Giai đoạn A - Chuẩn hóa dữ liệu mock
- Tạo file mock-recipes.json.
- Ban đầu 30 món, sau đó mở rộng 40 món để đa dạng case test.
- Chuẩn schema mỗi món:
  - id
  - name
  - image
  - ingredients[]
  - shortInstructions
  - updatedAt
- Mục tiêu test:
  - AC-01: có nhiều món chứa "trứng".
  - AC-02: từ khóa không tồn tại (ví dụ: XYZ123) trả empty.

### Giai đoạn B - Khởi tạo Flutter project
- Tạo project Flutter và tích hợp asset JSON.
- Khởi tạo màn hình tìm kiếm cơ bản:
  - TextField + nút Tìm.
  - Render danh sách món.
  - 4 trạng thái UI: loading/loaded/empty/error.
- Kết quả:
  - Đạt AC-01, AC-02 bản cơ bản.

### Giai đoạn C - Triển khai Offline cache (AC-03)
- Thêm package shared_preferences.
- Lưu cache theo từ khóa truy vấn.
- Bổ sung chế độ giả lập offline bằng Switch.
- Khi offline:
  - Có cache: hiển thị kết quả cache.
  - Không cache: báo lỗi rõ ràng.
- Kết quả:
  - Đạt luồng AC-03 ở mức MVP.

### Giai đoạn D - Cải tiến theo phản hồi thực tế
- Vấn đề 1: Dễ chạy nhầm project do workspace có nhiều thư mục Flutter.
  - Xử lý: đồng bộ mã về đúng project đang chạy (kitchen).
- Vấn đề 2: Tìm kiếm tiếng Việt không dấu chưa match.
  - Xử lý: chuẩn hóa chuỗi tiếng Việt có dấu -> không dấu khi search.
  - Kết quả: "tom" match "tôm", "trung" match "trứng".
- Vấn đề 3: Query rỗng kết quả vẫn lưu cache gây lãng phí slot.
  - Xử lý: không lưu cache cho truy vấn empty result.
- Vấn đề 4: Giới hạn cache 5 hơi chật.
  - Xử lý: nâng lên 10 truy vấn gần nhất (LRU).
- Vấn đề 5: Khó demo trực quan cache.
  - Xử lý: thêm panel hiển thị từ khóa cache + nút Xóa cache + chip bấm tìm lại.

### Giai đoạn E - Chuẩn hóa kiến trúc và kiểm thử tự động
- Tách module khỏi main.dart thành các nhóm:
  - models: recipe.dart, cache_lookup_result.dart
  - services: search_text_service.dart, recipe_cache_service.dart
  - pages: kitchen_search_page.dart
- Bổ sung unit test cho SearchTextService:
  - kiểm tra normalize tiếng Việt có dấu -> không dấu
  - kiểm tra match theo tên/nguyên liệu (tom = tôm)
- Cập nhật widget test để phù hợp luồng dữ liệu async.
- Kết quả xác nhận:
  - flutter test: pass toàn bộ.
  - flutter analyze: không có issue.

## 4. Quy tắc cache hiện tại
- Giới hạn: 10 từ khóa gần nhất.
- Chính sách: LRU (mới nhất lên đầu, vượt ngưỡng thì loại cũ nhất).
- Không lưu cache cho truy vấn không có kết quả.
- Offline lookup:
  - Ưu tiên khớp chính xác từ khóa.
  - Nếu không có, thử fallback gần đúng.
  - Nếu vẫn không có, báo lỗi kèm danh sách từ khóa đã cache.

## 5. Những thay đổi quan trọng trong code
- File chính: kitchen/lib/main.dart
  - Thêm model Recipe.toJson().
  - Thêm logic normalize tiếng Việt không dấu.
  - Thêm SharedPreferences cache manager nội tuyến.
  - Thêm Switch giả lập offline.
  - Thêm panel cache (x/10, danh sách chip, nút xóa).
- Cấu hình package: kitchen/pubspec.yaml
  - Bổ sung dependency shared_preferences.
- Dữ liệu: kitchen/assets/data/mock-recipes.json
  - Đồng bộ dữ liệu món ăn đa dạng để test.

## 6. Vấn đề đã gặp và cách xử lý (để thuyết trình)
- Lỗi không thấy nút offline:
  - Nguyên nhân: chạy nhầm project khác trong workspace.
  - Cách xử lý: xác định đúng project, đồng bộ code, chạy lại pub get.
- Cảnh báo/issue Flutter analyze:
  - Cập nhật code theo API mới và kiểm tra lại bằng flutter analyze.
- Asset không tồn tại:
  - Tạo lại thư mục assets/data và copy mock-recipes.json đúng vị trí.

## 7. Checklist demo gợi ý (5-7 phút)
1. Mở app, giới thiệu mục tiêu tìm món theo nguyên liệu.
2. Demo AC-01:
   - Nhập "trứng" -> hiển thị danh sách món phù hợp.
3. Demo AC-02:
   - Nhập "XYZ123" -> hiển thị Empty State.
4. Demo AC-03:
   - Online tìm "tôm" (để cache).
   - Bật Offline mode.
   - Tìm lại "tom" hoặc "tôm" -> kết quả từ cache.
5. Mở panel cache:
   - Cho xem số từ khóa đã lưu.
   - Bấm chip để tìm lại nhanh.
   - Bấm "Xóa cache" để reset.
6. Kết luận: bám sát BRD/SRS/AC + có minh chứng test.

## 8. Bài học rút ra
- Làm tài liệu trước giúp code ít lệch scope.
- Traceability FR -> AC -> Test giúp demo tự tin hơn.
- Cache cần quy tắc rõ (giới hạn, eviction, khi nào lưu/không lưu).
- Với tiếng Việt, normalize không dấu là rất cần cho UX.

## 9. Việc nên làm tiếp
- Bổ sung test tự động cho cache lookup (exact/fallback/eviction).
- Hoàn tất dry-run checklist trong KitchenSearch-AC-TestCases.md và tick Phase 3 đầy đủ.
