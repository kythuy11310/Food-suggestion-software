# SRS - Kitchen Search MVP

## 1. Tổng quan hệ thống
Ứng dụng web tìm món ăn theo nguyên liệu, dùng Mock API, có quản lý trạng thái cơ bản và cơ chế cache để tăng tốc độ phản hồi cũng như hỗ trợ offline fallback.

## 2. Yêu cầu chức năng (Functional Requirements)

### FR-01: Tìm kiếm theo nguyên liệu
- Cho phép nhập một hoặc nhiều nguyên liệu.
- Bắt đầu tìm kiếm khi nhấn nút Search hoặc Enter.
- Nếu input rỗng, hiển thị thông báo hợp lệ.

### FR-02: Hiển thị danh sách kết quả
- Hiển thị card món ăn gồm: tên món, ảnh, nguyên liệu chính, hướng dẫn ngắn.
- Giao diện responsive cho desktop và mobile.

### FR-03: Trạng thái loading
- Trong lúc gọi dữ liệu, hiển thị loading placeholders.

### FR-04: Trạng thái empty
- Nếu không có kết quả, hiển thị thông báo gợi ý tìm lại.

### FR-05: Trạng thái error và retry
- Nếu lỗi mạng hoặc API, hiển thị thông báo lỗi rõ ràng.
- Có nút Retry để gọi lại.

### FR-06: Lịch sử tìm kiếm
- Lưu tối đa 5 từ khóa tìm kiếm gần đây.
- Cho phép bấm lại từ khóa để tìm nhanh.

### FR-07: Caching
- Dùng memory cache cho kết quả vừa tìm.
- Dùng localStorage để fallback khi mất mạng.

### FR-08: Offline fallback
- Nếu offline và có cache, hiển thị dữ liệu cache + banner thông báo.
- Nếu offline và không có cache, hiển thị error state.

## 3. Yêu cầu phi chức năng (Non-Functional Requirements)
- NFR-01 (Hiệu năng): Kết quả cache trả về <= 100ms.
- NFR-02 (Tương thích): Hoạt động trên Chrome/Edge/Firefox bản mới.
- NFR-03 (Trải nghiệm): Hiển thị rõ 4 trạng thái loading/loaded/empty/error.
- NFR-04 (Bảo trì): Tách module API, state, UI, cache.

## 4. Mô hình dữ liệu mock

### RecipeSummary
- id: string
- name: string
- image: string
- ingredients: string[]
- shortInstructions: string

### SearchResult
- query: string
- total: number
- items: RecipeSummary[]
- fetchedAt: string (ISO)

## 5. Quy tắc nghiệp vụ
- BR-01: Query được trim khoảng trắng đầu/cuối.
- BR-02: Query không vượt quá 50 ký tự.
- BR-03: Chỉ lưu tối đa 5 từ khóa tìm kiếm gần nhất.
- BR-04: Khi offline, chỉ hiển thị dữ liệu đã có trong cache.
- BR-05: Cache có thời hạn 7 ngày.

## 6. Ma trận truy vết FR -> AC
- FR-01 -> AC-01, AC-02
- FR-02 -> AC-03
- FR-03 -> AC-04
- FR-04 -> AC-05
- FR-05 -> AC-06
- FR-06 -> AC-07
- FR-07 -> AC-08, AC-09
- FR-08 -> AC-10
