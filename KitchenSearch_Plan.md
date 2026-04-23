## Plan: Kitchen Search MVP theo BRD/SRS/AC

Mục tiêu là xây app Món ăn theo Nguyên liệu theo đúng quy trình tài liệu: chốt bối cảnh nghiệp vụ và phạm vi bằng BRD, đặc tả chi tiết bằng SRS, rồi định nghĩa Acceptance Criteria để nghiệm thu. Hướng triển khai đề xuất dùng Mock API ổn định cho demo, dữ liệu mức trung bình (tên món, ảnh, danh sách nguyên liệu, hướng dẫn ngắn), có fallback offline từ cache.

## 1. Các bước thực hiện

### Phase 1 - Khởi tạo bối cảnh và phạm vi dự án
1. Xác định problem statement, đối tượng người dùng, mục tiêu nghiệp vụ, KPI đo lường cho Kitchen Search.
2. Chốt in-scope và out-of-scope rõ ràng để tránh trượt phạm vi đồ án.
3. Đầu ra: BRD bản nháp 1 trang làm baseline cho toàn bộ tài liệu sau.

### Phase 2 - Thiết kế yêu cầu phần mềm từ BRD
1. Từ BRD, viết SRS với nhóm yêu cầu chức năng: tìm món theo nguyên liệu, hiển thị danh sách món, xem chi tiết ngắn, lưu lịch sử tìm kiếm, cache dữ liệu, fallback offline.
2. Viết yêu cầu phi chức năng: thời gian phản hồi, khả năng dùng trên mobile, hành vi khi lỗi mạng, tiêu chuẩn accessibility cơ bản.
3. Đặc tả cấu trúc dữ liệu mock: recipe summary và recipe detail; định nghĩa ràng buộc dữ liệu tối thiểu cho demo.

### Phase 3 - Thiết kế AC và tư duy test-first
1. Viết bộ Acceptance Criteria theo Given-When-Then cho toàn bộ luồng chính và luồng lỗi.
2. Dẫn xuất test checklist từ AC theo vai trò QA để Dev tự soát trước khi demo.
3. Gắn traceability: mỗi AC phải map về yêu cầu SRS tương ứng.

### Phase 4 - Kiến trúc triển khai MVP dựa trên kiến thức HTML đã học
1. Tổ chức kiến trúc frontend theo các mô-đun: API client, model mapping, state container, cache layer, renderer UI states.
2. Tái sử dụng pattern từ chuỗi bài học: async/await, parse JSON thành model, REST call có xử lý lỗi, state container, loading-error-empty-loaded, cache + search optimization.
3. Định nghĩa roadmap thực thi theo sprint nhỏ: Core MVP trước, tối ưu sau.

### Phase 5 - Kế hoạch nghiệm thu và demo
1. Chuẩn bị bộ minh chứng: BRD, SRS, AC, test checklist, video luồng nghiệp vụ, bảng đối chiếu yêu cầu-đầu ra.
2. Lập script demo theo AC để đảm bảo khả năng nghiệm thu và thuyết phục theo chuẩn dự án thực tế.

## 2. Tài liệu tham chiếu
- c:/Users/Le Hoang/Desktop/coding/app/bai_tap_01_api_va_backend.html - tham chiếu nền tảng API/Backend và ngữ cảnh REST khi viết FR liên quan tích hợp dữ liệu.
- c:/Users/Le Hoang/Desktop/coding/app/bai_tap_02_async_await.html - tham chiếu luồng async/await và xử lý lỗi bất đồng bộ cho FR gọi dữ liệu.
- c:/Users/Le Hoang/Desktop/coding/app/bai_tap_03_json_va_model.html - tham chiếu chuẩn hóa model JSON cho recipe summary/detail.
- c:/Users/Le Hoang/Desktop/coding/app/bai_tap_04_restful_api.html - tham chiếu pattern REST client, phân loại lỗi API.
- c:/Users/Le Hoang/Desktop/coding/app/bai_tap_05_api_va_state_container.html - tham chiếu state container để quản lý trạng thái tìm kiếm.
- c:/Users/Le Hoang/Desktop/coding/app/bai_tap_06_loading_error_empty_state.html - tham chiếu thiết kế 4 trạng thái UI.
- c:/Users/Le Hoang/Desktop/coding/app/bai_tap_07_pagination_cache_search.html - tham chiếu cache và tối ưu tìm kiếm cho offline fallback.

## 3. Kế hoạch kiểm tra
1. Review chéo BRD: kiểm tra đủ bối cảnh, mục tiêu, scope và out-of-scope.
1. Review chéo SRS: kiểm tra đầy đủ functional/non-functional requirements và tính khả thi theo Mock API.
1. Kiểm tra traceability: mỗi yêu cầu SRS có ít nhất một AC; mỗi AC map ngược được về SRS.
1. Dry-run nghiệm thu: chạy lần lượt các kịch bản AC (happy path, empty, error, offline cached) và ghi kết quả pass/fail.
1. Demo rehearsal: trình bày theo thứ tự nghiệp vụ -> đặc tả -> kiểm thử -> kết quả để bám đúng trọng tâm môn học.

## 4. Quyết định đã chốt
- Đã chốt nguồn dữ liệu là Mock API để ổn định demo và giảm rủi ro quota/key.
- Đã chốt độ sâu dữ liệu mức trung bình: tên món, ảnh, danh sách nguyên liệu, hướng dẫn ngắn.
- Đã chốt yêu cầu offline cho MVP: ưu tiên hiển thị dữ liệu đã cache khi mất mạng.
- Ưu tiên số 1: đúng quy trình tài liệu BRD/SRS/AC, coi đây là tiêu chí trọng tâm cho nghiệm thu.
- In scope: quy trình tài liệu và luồng nghiệp vụ tìm món theo nguyên liệu.
- Out of scope: đăng nhập người dùng, phân quyền nhiều vai trò, recommendation AI cá nhân hóa, thanh toán, analytics nâng cao.

## 5. Lưu ý thêm
1. Nên chuẩn hóa template tài liệu trước khi viết chi tiết. Khuyến nghị: Option A dùng 1 mẫu BRD/SRS/AC xuyên suốt để dễ traceability; Option B viết tự do rồi hợp nhất sau.
1. Nên chốt sớm số lượng bản ghi mock data cho demo. Khuyến nghị: Option A 30-50 món để đủ đa dạng; Option B 10-15 món cho demo nhanh.
1. Nên xác định mức kiểm thử mong muốn. Khuyến nghị: Option A test checklist thủ công đầy đủ theo AC; Option B thêm test tự động tối thiểu cho các hàm xử lý dữ liệu.