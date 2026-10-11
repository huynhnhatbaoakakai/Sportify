# Tiến độ luyện vấn đáp Sportify

## Trạng thái

- /scan đã tạo SPORTIFY_VIVA_MAP.md và kiểm tra cấu trúc/evidence links/source hashes thành công; DB SELECT và HTTP GET có output thật, chưa build/POST end-to-end.
- Câu 1 được giao sau khi hoàn tất scan: “Em hãy giới thiệu Sportify và phân biệt phần em trực tiếp thực hiện với phần Booking của nhóm.” Đang chờ câu trả lời; chưa chấm điểm.
- Chưa có điểm số, chủ đề mạnh/yếu chưa được đánh giá. Có tài liệu không đồng nghĩa đã hiểu.
- Phạm vi đóng góp do người học khai báo: owner dashboard/quản lý sân/model/database access/status/PostgreSQL/chat persistence/reviews đang hoàn thiện/demo owner access.
- Booking thuộc thành viên khác. Customers mới xuất hiện trong source chưa xác nhận tác giả/đóng góp cá nhân.

## Rubric mỗi câu (10 điểm)

- Kỹ thuật: 0–4.
- Dẫn đúng file/class/method: 0–3.
- Flow: 0–2.
- Ngắn gọn/tự tin: 0–1 (không suy cảm xúc ngoài nội dung trình bày).

## Nhật ký câu trả lời

| Câu | Chế độ/chủ đề | Câu trả lời người học | Kỹ thuật/4 | Code/3 | Flow/2 | Trình bày/1 | Tổng/10 | Sai/thiếu | Câu vặn/kế hoạch ôn |
|---|---|---|---|---|---|---|---|---|---|

## Các điểm cần phân biệt khi luyện

- Java source/target17 hiện tại, không Java8 mô tả ban đầu.
- JPA/JPQL/Hibernate, không tự viết PreparedStatement trong DAO hiện tại.
- DB read verified khác web end-to-end verified; context thử /sportify đang404.
- Owner flag demo khác login/role thật; owner1 scoping chưa multi-owner auth.
- Booking DOM/revenue mock khác sân/reviews/chat có DAO persistence.
- EL/JSTL/custom tags trong slide chưa render model trong source.
- Source/DB đang thay đổi; reviews đã có trong lần đọc mới, không giữ kết luận absent cũ.

## Quy tắc tương tác

Một câu mỗi lượt, không đáp án trước, chờ trả lời. Sau đó chấm chặt theo rubric, chỉ rõ đúng/sai/thuật ngữ/file cần mở, mẫu20–45giây và một câu vặn sâu. Chỉ ghi yếu sau câu trả lời thật. Các lệnh /viva /random /code /flow /slide /debug /demo /rapid /weak /report theo SPORTIFY_VIVA_MAP.md.
