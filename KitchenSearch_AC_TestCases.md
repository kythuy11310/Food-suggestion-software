# Acceptance Criteria và Test Cases

## 1. AC trọng yếu dùng cho nghiệm thu

| Mã AC trọng yếu | Tiêu chí nghiệm thu | Cách kiểm tra nhanh khi demo | Map tới AC chi tiết |
| --- | --- | --- | --- |
| AC-01 | Tìm kiếm theo nguyên liệu có kết quả. | Nhập "Trứng" -> hiển thị danh sách món có trứng (ví dụ: Khổ qua xào trứng). | AC-01, AC-03 |
| AC-02 | Xử lý khi nguyên liệu không tồn tại. | Nhập "XYZ123" -> hiển thị Empty State: "Không tìm thấy món ăn nào". | AC-05 |
| AC-03 | Khả năng truy cập ngoại tuyến (Offline). | Xem món A khi có mạng -> tắt mạng -> mở lại món A -> dữ liệu vẫn hiển thị từ cache. | AC-10 |

## 2. Acceptance Criteria chi tiết (Given - When - Then)

### AC-01: Tìm kiếm với một nguyên liệu
Given người dùng mở ứng dụng
When nhập "chicken" và nhấn Search
Then hệ thống hiển thị danh sách món phù hợp

### AC-02: Tìm kiếm với nhiều nguyên liệu
Given người dùng mở ứng dụng
When nhập "chicken, tomato"
Then hệ thống trả kết quả liên quan tới cả hai nguyên liệu

### AC-03: Nội dung card kết quả
Given có kết quả tìm kiếm
When danh sách được render
Then mỗi card có tên, ảnh, nguyên liệu và hướng dẫn ngắn

### AC-04: Trạng thái loading
Given người dùng bắt đầu tìm kiếm
When request đang xử lý
Then loading state được hiển thị

### AC-05: Trạng thái empty
Given query không có kết quả
When API trả về danh sách rỗng
Then hiển thị empty state và gợi ý tìm lại

### AC-06: Trạng thái error và retry
Given xảy ra lỗi mạng/API
When request thất bại
Then hiển thị error state và nút Retry

### AC-07: Lịch sử tìm kiếm
Given người dùng đã tìm kiếm trước đó
When focus vào ô tìm kiếm
Then có thể chọn lại từ khóa đã tìm

### AC-08: Hiệu năng khi cache hit
Given query đã có trong cache
When tìm lại query đó
Then kết quả được trả nhanh từ cache

### AC-09: TTL của cache
Given dữ liệu cache đã quá hạn
When tìm lại query
Then bỏ cache cũ và lấy dữ liệu mới

### AC-10: Offline fallback
Given người dùng đang offline
When tìm query đã từng cache
Then hiển thị kết quả cache và thông báo offline

## 3. Checklist kiểm thử thủ công
- [ ] TC-01: Tìm kiếm nguyên liệu đơn
- [ ] TC-02: Tìm kiếm nhiều nguyên liệu
- [ ] TC-03: Kiểm tra input rỗng
- [ ] TC-04: Kiểm tra loading state
- [ ] TC-05: Kiểm tra empty state
- [ ] TC-06: Kiểm tra error state và Retry
- [ ] TC-07: Kiểm tra lịch sử tìm kiếm
- [ ] TC-08: Kiểm tra cache hit
- [ ] TC-09: Kiểm tra cache hết hạn
- [ ] TC-10: Kiểm tra offline fallback

## 4. Nhật ký thực thi test
- Tester:
- Ngày:
- Môi trường:
- Tổng kết kết quả: Pass / Fail
- Lỗi phát hiện:

## 5. Mức kiểm thử đã chốt
- Manual-first: chạy đầy đủ checklist TC-01 đến TC-10 khi nghiệm thu.
- Automated tối thiểu: 1 widget test smoke để xác nhận app render màn hình Kitchen Search.
- Ghi nhận kết quả: đính kèm ảnh/chụp màn hình test pass trong báo cáo demo.
