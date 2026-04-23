# Kitchen Search - Theo dõi Tiến độ

Ngày bắt đầu: 2026-04-20
Trạng thái tổng thể: In Progress (đang ở Phase 4)

## 1. Mục tiêu ưu tiên
- Hoàn thành BRD -> SRS -> AC trước khi viết code MVP.
- MVP dùng Mock API, dữ liệu mức trung bình.
- Có offline fallback từ cache.

## 2. Tiến độ theo phase

### Phase 1 - BRD
- [x] Problem statement
- [x] User persona
- [x] Business goals + KPI
- [x] In-scope / Out-of-scope
- [x] BRD review

### Phase 2 - SRS
- [x] Functional requirements
- [x] Non-functional requirements
- [x] Data model (mock)
- [x] Error + offline handling
- [x] SRS review

### Phase 3 - AC + Test Checklist
- [x] Viết AC theo Given-When-Then
- [x] Map AC -> FR (traceability)
- [x] Test checklist thủ công
- [ ] Dry-run: happy path, empty, error, offline

### Phase 4 - MVP Blueprint
- [x] Chốt cấu trúc module
- [x] Chốt luồng dữ liệu và state
- [x] Chốt chiến lược cache

### Phase 5 - Demo Readiness
- [ ] Bộ minh chứng BRD/SRS/AC/Test
- [ ] Script demo
- [ ] Rehearsal 1 lần

## 3. Nhật ký
- 2026-04-20: Chốt plan tổng thể.
- 2026-04-20: Tạo bộ tài liệu BRD/SRS/AC/Progress cục bộ.
- 2026-04-20: Chuẩn hóa tài liệu tiếng Việt có dấu và sắp xếp lại nội dung.
- 2026-04-20: Đồng bộ AC trọng yếu trong tài liệu test theo BRD (mục 12-15).
- 2026-04-20: Tạo Flutter project kitchen_search_flutter và tích hợp assets mock-recipes.json.
- 2026-04-20: Hoàn thành màn hình tìm kiếm cơ bản trong Flutter, đạt AC-01 và AC-02.
- 2026-04-20: Chốt mức kiểm thử: manual-first + automated tối thiểu (1 widget test smoke).
- 2026-04-20: Triển khai offline cache bằng SharedPreferences và thêm chế độ giả lập offline để test AC-03.
- 2026-04-20: Tách module code Flutter thành models/services/pages để giảm phụ thuộc vào main.dart.
- 2026-04-20: Bổ sung unit test SearchTextService (tìm kiếm không dấu) và cập nhật widget test theo luồng async.

## 4. Blocker đang mở
- [x] Chốt số lượng mock recipes cho demo (đề xuất 30-50).
- [x] Chốt mức kiểm thử (manual-first + auto test tối thiểu).

## 5. Quyết định kiểm thử đã chốt
- Chiến lược: Manual-first, ưu tiên chạy checklist AC trong demo.
- Tự động tối thiểu: 1 widget test smoke để xác nhận app render được màn hình chính.
- Lý do: Phù hợp thời lượng đồ án, vẫn có minh chứng chất lượng ngoài kiểm thử tay.
