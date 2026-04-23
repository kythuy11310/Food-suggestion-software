# BRD - Kitchen Search (Món Ăn Theo Nguyên Liệu)

## 1. Bối cảnh nghiệp vụ
Ứng dụng hỗ trợ người dùng tìm món ăn dựa trên nguyên liệu sẵn có trong bếp. Đồ án tập trung vào quy trình phát triển phần mềm thực tế: phân tích yêu cầu, đặc tả, nghiệm thu, sau đó mới triển khai.

## 2. Tuyên bố vấn đề
Người dùng thường có nguyên liệu nhưng không biết nấu món gì phù hợp. Cần một công cụ tìm kiếm nhanh, dễ dùng, hoạt động tốt trên web và thiết bị di động.

## 3. Người dùng mục tiêu
- Người mới học nấu ăn.
- Người dùng cần tra cứu nhanh trên điện thoại.
- Người dùng muốn xem công thức ngắn gọn, dễ làm theo.

## 4. Mục tiêu kinh doanh
- G1: Tìm được danh sách món phù hợp theo nguyên liệu đầu vào.
- G2: Trải nghiệm rõ ràng theo 4 trạng thái UI: loading, loaded, empty, error.
- G3: Thể hiện đầy đủ quy trình BRD -> SRS -> AC trong đồ án.

## 5. Chỉ số thành công
- Thời gian phản hồi tìm kiếm <= 2 giây (trừ trường hợp mạng chậm).
- Truy vấn trùng lặp trả kết quả từ cache <= 100ms.
- 100% AC trọng yếu đạt trạng thái Pass khi demo nghiệm thu.

## 6. Phạm vi trong dự án (In Scope)
- Tìm món theo một hoặc nhiều nguyên liệu.
- Hiển thị danh sách món và thông tin chi tiết ngắn.
- Lưu lịch sử tìm kiếm gần đây.
- Có cache và fallback offline khi có dữ liệu cũ.

## 7. Phạm vi ngoài dự án (Out of Scope)
- Đăng nhập, phân quyền.
- Thanh toán.
- Gợi ý AI nâng cao, cá nhân hóa sâu.
- Phân tích hành vi người dùng nâng cao.

## 8. Ràng buộc
- Nguồn dữ liệu: Mock API.
- Ưu tiên tính ổn định, dễ demo.
- Nền tảng: HTML/CSS/JavaScript.

## 9. Các bên liên quan
- Nhóm dự án: PM, BA, Dev, Test (sinh viên kiêm nhiệm).
- Giảng viên: bên nghiệm thu.

## 10. Rủi ro chính
- Dữ liệu mock ít gây nghèo kết quả.
- Trượt phạm vi khi thêm tính năng ngoài MVP.
- Thiếu truy vết giữa yêu cầu chức năng và AC.

## 11. Phê duyệt
- [ ] PM đồng ý
- [ ] BA đồng ý
- [ ] Dev đồng ý
- [ ] Test đồng ý

## 12. Business Process Mapping (Sơ đồ quy trình nghiệp vụ)

### 12.1 Quy trình hiện tại (Thủ công)
1. Người dùng kiểm tra tủ lạnh để xem nguyên liệu còn lại.
2. Người dùng cố nhớ các món đã từng ăn hoặc tra cứu rời rạc qua sách nấu ăn/Google.
3. Người dùng mất thời gian chọn lọc món phù hợp.

### 12.2 Quy trình mong muốn (Tin học hóa)
1. Người dùng nhập nguyên liệu vào ứng dụng.
2. Ứng dụng truy vấn Mock API.
3. Ứng dụng hiển thị danh sách món ăn phù hợp gần như ngay lập tức.
4. Người dùng chọn món và xem hướng dẫn ngắn.

### 12.3 Giá trị cải tiến
- Rút ngắn thời gian ra quyết định chọn món.
- Giảm phụ thuộc vào việc ghi nhớ thủ công.
- Tăng tính nhất quán của trải nghiệm tra cứu công thức.

## 13. Business Rules (Quy tắc nghiệp vụ)
- BR-01 (Tìm kiếm): Phải nhập ít nhất một nguyên liệu hoặc từ khóa mới được phép thực hiện lệnh tìm kiếm.
- BR-02 (Kết quả): Danh sách món ăn trả về phải chứa ít nhất một nguyên liệu khớp với từ khóa người dùng nhập.
- BR-03 (Lịch sử): Chỉ lưu tối đa 5 từ khóa tìm kiếm gần nhất để tối ưu bộ nhớ đệm (cache).
- BR-04 (Offline): Khi mất mạng, hệ thống chỉ hiển thị dữ liệu đã được lưu trong cache từ lần truy cập cuối cùng.

## 14. Stakeholder Concerns (Mối quan tâm của các bên)
- Giảng viên (Bên nghiệm thu): Quan tâm tính đúng đắn của quy trình SDLC và khả năng truy vết từ tài liệu đến mã nguồn.
- Người dùng (Sinh viên): Mong muốn giao diện đơn giản, phản hồi nhanh (search response <= 2 giây), và hoạt động ổn định khi mạng chập chờn.
- Team phát triển (PM/BA/Dev/Test): Ưu tiên tính ổn định của Mock API để demo trơn tru, giảm rủi ro phụ thuộc bên thứ ba.

## 15. Key Acceptance Criteria (Tiêu chí nghiệm thu chính)

| Mã AC | Tiêu chí nghiệm thu | Phương pháp kiểm tra (Nghiệm thu) |
| --- | --- | --- |
| AC-01 | Tìm kiếm theo nguyên liệu có kết quả. | Nhập "Trứng" -> hiển thị danh sách món có trứng (ví dụ: Khổ qua xào trứng). |
| AC-02 | Xử lý khi nguyên liệu không tồn tại. | Nhập "XYZ123" -> hiển thị Empty State: "Không tìm thấy món ăn nào". |
| AC-03 | Khả năng truy cập ngoại tuyến (Offline). | Xem món A khi có mạng -> tắt mạng -> mở lại món A -> dữ liệu vẫn hiển thị từ cache. |
