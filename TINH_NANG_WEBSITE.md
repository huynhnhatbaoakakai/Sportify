# Các tính năng hiện có của website Sportify

Cập nhật ngày 17/10/2026. Tài liệu mô tả chức năng đang có trong mã nguồn, tập trung vào đặt sân, quản lý sân, tương tác chủ sân–khách hàng, chat và mạng xã hội. Những phần mới có giao diện hoặc chưa hoàn thiện được ghi riêng ở cuối để tránh nhầm với chức năng đã hoạt động.

## 1. Khám phá sân trên trang giới thiệu

Khách chưa đăng nhập có thể xem các nhóm gym, bóng rổ, bơi và pickleball. Trang giới thiệu có ô tìm kiếm theo môn thể thao, nút xóa bộ lọc, số kết quả và thông báo khi không tìm thấy. Tìm kiếm hỗ trợ từ khóa có dấu hoặc không dấu.

Các thẻ theo môn dùng hình minh họa và dẫn đến danh sách sân đang hoạt động sau đăng nhập. Giá và lịch trống thực tế được xem tại sân cụ thể. Nút đặt sân đi vào luồng gửi đơn cho chủ sân.

Trang giới thiệu có lối vào theo dõi đơn đặt sân, nhắn tin và cộng đồng. Tài khoản chủ sân có thêm nút quản lý sân. Các mục thuê gear, trang phục và huấn luyện viên đã được tắt.

## 2. Đăng ký, đăng nhập và đăng xuất

Khách có thể đăng ký bằng họ tên, email, mật khẩu và mật khẩu xác nhận. Hệ thống kiểm tra thông tin cơ bản, độ dài mật khẩu, mật khẩu xác nhận và email đã được sử dụng. Tài khoản đăng ký thông thường nhận vai trò khách hàng.

Người dùng đăng nhập bằng email và mật khẩu của mình. Tài khoản chủ sân được cấp quyền chủ sân trước khi sử dụng khu vực quản lý. Khi đăng nhập thành công, khách hàng vào trang cá nhân còn chủ sân vào bảng quản lý sân. Chủ sân vẫn có thể chuyển về giao diện khách hàng.

Mật khẩu mới được lưu dưới dạng băm. Tài khoản cũ còn dùng mật khẩu dạng văn bản được chuyển sang dạng băm khi đăng nhập thành công. Đăng xuất kết thúc phiên đăng nhập. Khu vực chủ sân dùng quyền của tài khoản đăng nhập, thay cho mật khẩu demo dùng chung.

## 3. Trang tổng quan của khách hàng

Sau đăng nhập, người dùng xem được số đơn đặt sân, số lịch nhắc cá nhân sắp tới, danh sách lịch nhắc sắp đến, các sân đang hoạt động và những đơn đặt sân của chính mình.

Danh sách sân hiển thị thông tin sân, môn thể thao, địa chỉ, giờ mở cửa, hình ảnh, mô tả và giá theo giờ. Người dùng có thể chọn một sân để mở trang đặt lịch riêng cho sân đó.

## 4. Xem lịch trống trước khi đặt sân

Tại trang đặt sân, khách chọn ngày để xem các khoảng giờ trong thời gian mở cửa. Giao diện chia thành ba bước chọn ngày, chọn giờ và thông tin liên hệ; có nút Hôm nay, Ngày mai và chọn nhanh thời lượng 30 phút, 1 giờ, 1,5 giờ hoặc 2 giờ. Khi mới mở trang hoặc đổi ngày, hệ thống chọn một giờ phù hợp trong khoảng còn trống, ưu tiên mốc 15 phút dễ nhớ; khách vẫn được điều chỉnh giờ theo phút.

Khoảng đang chọn có dấu nhận biết. Ngày, giờ, thời lượng và giá tạm tính được cập nhật ngay trước nút gửi. Số điện thoại đã lưu trong hồ sơ được điền sẵn. Nếu lựa chọn không hợp lệ, đang tải lịch hoặc đã hết chỗ, nút gửi bị tắt và có thông báo hướng dẫn. Khi lịch được tự làm mới, hệ thống giữ lựa chọn đang nhập và yêu cầu chọn lại nếu giờ đó không còn trống.

Trang đặt sân có bố cục riêng cho điện thoại, ô nhập lớn và nút gửi rõ ràng. Thông tin giá, giờ mở cửa và cách xác nhận lấy từ sân thật; không hiển thị điểm đánh giá hoặc tiện ích minh họa.

Lịch phân biệt giờ còn trống, đã được đặt, đã bị chủ sân khóa, đã qua thời gian đặt hoặc sân đang tạm ngưng.

Khách có thể bấm khoảng giờ còn trống để điền giờ bắt đầu và kết thúc, sau đó điều chỉnh theo nhu cầu. Hệ thống hiển thị thời lượng và số tiền tạm tính dựa trên giá sân. Lịch được làm mới mỗi 15 giây khi trang đang được xem và có nút làm mới thủ công.

Lịch trống mà khách nhìn thấy không công khai tên, email hay số điện thoại của người đã đặt sân. Thời gian đặt và lịch sân dùng giờ Việt Nam.

## 5. Tạo yêu cầu đặt sân và tự xác nhận

Khách đăng nhập có thể đặt sân bằng cách chọn ngày, giờ bắt đầu, giờ kết thúc và cung cấp số điện thoại liên hệ nếu cần. Hệ thống lấy danh tính người đặt từ tài khoản đang đăng nhập, tính tiền ở phía máy chủ và gắn đơn với tài khoản đó.

Trước khi lưu đơn, hệ thống kiểm tra sân có tồn tại và đang hoạt động, ngày giờ chưa qua, giờ kết thúc sau giờ bắt đầu, buổi chơi nằm trong cùng một ngày, nằm trong giờ mở cửa và không trùng lịch đã được xác nhận hoặc giờ bị khóa. Khoảng đặt có độ chính xác đến phút.

Với sân duyệt thủ công, yêu cầu hợp lệ được đưa vào trạng thái chờ xác nhận. Với sân bật tự xác nhận, yêu cầu hợp lệ được xác nhận và giữ chỗ ngay, khách không cần chờ chủ sân bấm duyệt. Hệ thống tự tạo thông báo và ghi lại cách xác nhận.

Khi nhiều khách đặt cùng một khoảng giờ, chỉ một đơn được xác nhận. Đơn còn lại nhận thông báo không còn chỗ và cần chọn giờ khác. Hai buổi chơi liền nhau, chẳng hạn 08:00–09:00 và 09:00–10:00, được phép tồn tại.

Nếu khách đã có một yêu cầu chờ duyệt trùng giờ trên cùng sân, hệ thống ngăn gửi yêu cầu lặp lại. Đơn chờ duyệt chưa giữ chỗ và chưa làm mất khoảng giờ trống đối với khách khác.

## 6. Xem và hủy đơn của khách hàng

Khách xem được mã đơn, sân, ngày chơi, giờ chơi, tổng tiền và trạng thái xử lý trong phần đơn đặt sân của mình. Trạng thái có thể là chờ xác nhận, đã xác nhận, bị từ chối, đã hủy hoặc đã hoàn thành.

Khách được hủy yêu cầu của chính mình khi đơn vẫn đang chờ xác nhận. Sau khi hủy, chủ sân và khách nhận được thông báo, đồng thời lịch sử xử lý được bổ sung. Đơn đã được xác nhận không có nút tự hủy trong phiên bản này; khách cần liên hệ chủ sân để được hỗ trợ.

## 7. Quản lý sân theo tài khoản chủ sân

Mỗi chủ sân xem và thao tác trên các sân thuộc tài khoản của mình. Chủ sân có thể thêm sân, sửa tên, môn thể thao, địa chỉ, giá theo giờ, giờ mở cửa, giờ đóng cửa và trạng thái hoạt động.

Khi lưu, hệ thống kiểm tra thông tin bắt buộc, môn thể thao được hỗ trợ, giá thuê dương và giờ đóng cửa sau giờ mở cửa. Chủ sân có thể tạm ngưng hoặc kích hoạt lại sân. Sân tạm ngưng không nhận yêu cầu đặt mới.

Chủ sân có thể mở lịch theo ngày ngay từ thẻ sân, bật hoặc tắt tự xác nhận đối với các sân đủ điều kiện và chuyển nhanh giữa trang quản lý sân, danh sách đơn và lịch sân.

## 8. Bật hoặc tắt tự xác nhận riêng cho từng sân

Tự xác nhận hiện áp dụng cho sân thuê riêng thuộc môn bóng rổ và pickleball. Chủ sân quyết định bật hoặc tắt trên từng sân. Gym và hồ bơi vẫn dùng chế độ duyệt thủ công vì phiên bản hiện tại chưa quản lý đặt theo sức chứa nhiều người.

Các sân cũ mặc định giữ chế độ duyệt thủ công. Khi bật tự xác nhận, chỉ đơn mới được áp dụng. Những yêu cầu cũ đang chờ không tự chuyển sang đã xác nhận.

Nếu chủ sân đổi môn thể thao sang gym hoặc bơi, chế độ tự xác nhận được tắt. Dù sân bật tự xác nhận, mọi đơn vẫn phải thỏa điều kiện về trạng thái hoạt động, giờ mở cửa, lịch đã đặt và giờ bị khóa.

## 9. Lịch sân theo ngày dành cho chủ sân

Chủ sân chọn sân và ngày để xem lịch hoạt động, các khoảng còn trống, lịch đã được xác nhận, giờ khóa và thời gian đã qua. Trạng thái hoạt động của sân và tình trạng trống hoặc bận theo từng giờ được thể hiện riêng.

Lịch trực quan được làm mới theo chu kỳ. Chủ sân cũng xem được danh sách đơn trong ngày, gồm mã đơn, tên khách, giờ chơi, trạng thái và cách xác nhận. Danh sách chi tiết đơn được tải lại khi mở hoặc chọn lại lịch.

Từ lịch sân, chủ sân có thể bấm khoảng trống để điền nhanh thời gian cho biểu mẫu khóa giờ, chuyển chế độ xác nhận hoặc mở trang quản lý đơn để xử lý yêu cầu.

## 10. Khóa và mở lại giờ ngoại lệ

Chủ sân tạo khoảng giờ ngoại lệ để phục vụ bảo trì, sự kiện riêng hoặc khách đã đặt trực tiếp. Một khoảng khóa có thời điểm bắt đầu, thời điểm kết thúc và lý do hiển thị cho khách. Khoảng khóa có thể kéo dài qua nhiều ngày; lịch của mỗi ngày chỉ hiển thị phần nằm trong giờ mở cửa ngày đó.

Nếu khoảng cần khóa trùng với đơn đã được xác nhận hoặc đã hoàn thành, hệ thống chưa tạo lịch khóa và hiển thị mã những đơn bị ảnh hưởng. Chủ sân cần xử lý các đơn đó trước. Hệ thống cũng ngăn tạo hai khoảng khóa chồng nhau.

Giờ đã khóa chặn cả yêu cầu đặt mới lẫn thao tác xác nhận yêu cầu cũ đang chờ. Chủ sân được mở lại khoảng giờ đã khóa. Sau khi mở, khoảng giờ chỉ trở lại khả dụng nếu sân đang hoạt động, thời gian chưa qua và không có đơn đã giữ chỗ.

## 11. Quản lý và xử lý đơn đặt sân

Chủ sân xem danh sách đơn của các sân mình quản lý, lọc theo trạng thái và tìm theo mã đơn, tên khách, sân hoặc số điện thoại. Mỗi đơn hiển thị thông tin khách, sân, ngày giờ, tổng tiền và trạng thái.

Đơn chờ có nút xác nhận hoặc từ chối. Khi chủ sân xác nhận, hệ thống kiểm tra lại trạng thái sân, thời gian, giờ khóa và các đơn đã giữ chỗ tại thời điểm xử lý. Vì vậy, một yêu cầu từng hợp lệ lúc gửi vẫn có thể cần chọn giờ khác nếu lịch đã thay đổi.

Đơn đã xác nhận và đã kết thúc buổi chơi có nút để chủ sân xác nhận khách đã sử dụng sân, chuyển sang hoàn thành. Hệ thống không tự đánh dấu hoàn thành chỉ vì thời gian đã trôi qua.

## 12. Lịch sử xử lý đơn

Các đơn phát sinh hoặc được xử lý sau khi bật tính năng mới có lịch sử ghi nhận việc tạo yêu cầu, tự xác nhận, chủ sân duyệt, từ chối, khách hủy và chủ sân xác nhận hoàn thành.

Lịch sử thể hiện ai thực hiện theo vai trò khách hàng, chủ sân hoặc hệ thống, thời điểm và lý do. Đơn được tự xác nhận có nhãn riêng để chủ sân nhận biết. Lịch sử được lưu cùng giao dịch thay đổi đơn; nếu lưu đơn thất bại thì không ghi nhận một lần xử lý thành công.

Các đơn cũ trước khi có tính năng này được giữ nguyên và có thể chưa có lịch sử chi tiết. Màn hình quản lý hiển thị các diễn biến gần nhất.

## 13. Thông báo trong ứng dụng

Khách và chủ sân nhận thông báo khi có yêu cầu đặt mới, tự xác nhận, xác nhận thủ công, từ chối, khách hủy yêu cầu hoặc hoàn thành đơn. Nội dung giúp nhận biết mã đơn, sân, thời gian chơi và kết quả xử lý.

Mỗi tài khoản chỉ xem và đánh dấu thông báo của chính mình. Có số thông báo chưa đọc trong thanh điều hướng, trang xem 50 thông báo gần nhất, nút đánh dấu một thông báo đã đọc và nút đánh dấu tất cả đã đọc.

Số thông báo chưa đọc được kiểm tra lại mỗi 15 giây khi người dùng đang xem trang. Từ thông báo, người dùng có thể chuyển đến danh sách đơn liên quan. Thông báo hiện nằm trong website, chưa gửi email hoặc SMS.

## 14. Bảng tổng quan và thống kê của chủ sân

Bảng quản lý có thông tin về các sân đang hoạt động, số đơn trong ngày, số yêu cầu chờ xác nhận và doanh thu thống kê trong ngày. Danh sách đơn hôm nay không tính đơn đã hủy hoặc bị từ chối.

Doanh thu được tính từ những đơn đã hoàn thành theo ngày sử dụng sân. Đơn mới tự xác nhận chưa được coi là doanh thu hoàn thành. Việc xác nhận đã sử dụng sân do chủ sân thực hiện; hệ thống chưa đối soát tiền thực nhận qua cổng thanh toán.

## 15. Quản lý đánh giá

Chủ sân xem các đánh giá đã có trên những sân của mình, lọc theo số sao từ một đến năm, xem tổng số đánh giá và điểm trung bình. Danh sách hiển thị khách đánh giá, sân, số sao, nội dung và thời điểm.

Chủ sân được viết hoặc cập nhật phản hồi cho đánh giá thuộc sân của mình. Phản hồi được kiểm tra nội dung trống và độ dài tối đa 2.000 ký tự, có lưu thời điểm phản hồi. Hiện chưa có màn hình để khách tự tạo đánh giá mới.

## 16. Danh sách khách hàng đã đánh giá

Chủ sân có thể tìm khách theo tên, xem số đánh giá, số sân đã được đánh giá, điểm trung bình và lần đánh giá gần nhất. Các thống kê chỉ lấy dữ liệu từ những sân thuộc chủ sân hiện tại.

Danh sách này tổng hợp theo tên trong dữ liệu đánh giá. Đây chưa phải danh bạ đầy đủ của tất cả tài khoản từng đặt sân; hai người cùng tên có thể được gộp trong phần tổng hợp này.

## 17. Lịch nhắc cá nhân cho buổi chơi

Người dùng tạo lịch nhắc bằng tiêu đề, ngày, giờ và ghi chú. Lịch nhắc chỉ dành cho hoạt động đi sân; không còn tùy chọn thuê huấn luyện viên, dụng cụ hoặc trang phục.

Người dùng xem các lịch nhắc của mình qua hai nhóm sắp tới và đã qua, hoặc xóa lịch nhắc. Những lịch nhắc sắp tới xuất hiện trên trang tổng quan.

Màn hình có hướng dẫn và liên kết đến danh sách sân để gửi đơn giữ chỗ. Lưu lịch nhắc chỉ ghi nhớ kế hoạch cá nhân, không tạo đơn cho chủ sân và không giữ giờ trên sân.

Các lịch thuê dịch vụ cũ được giữ trong database nhưng không hiển thị trong luồng hiện tại. Máy chủ từ chối tạo mới những loại lịch thuê đã tắt, kể cả khi gửi yêu cầu trực tiếp.

## 18. Newsfeed cộng đồng

Người dùng đăng nhập có thể xem bài viết mới nhất, đăng nội dung, thích hoặc bỏ thích bài viết và gửi bình luận. Bài viết và bình luận hiển thị tác giả cùng thời gian đăng; số lượt thích được cập nhật sau thao tác.

Hệ thống kiểm tra nội dung bài viết và bình luận không được trống. Dữ liệu được lưu để có thể xem lại sau khi tải trang. Phiên bản hiện tại chưa có chức năng sửa hoặc xóa bài viết, tải ảnh lên hay quản trị kiểm duyệt nội dung.

## 19. Chat giữa chủ sân, khách hàng và người dùng

Người dùng đăng nhập xem các tài khoản khác trong hệ thống, chọn người để trò chuyện, gửi tin nhắn và xem các tin gần nhất. Giao diện có danh sách hội thoại, đoạn xem trước, thời gian, nội dung tin nhắn và phân biệt tin gửi với tin nhận.

Tại trang đặt sân và đơn đã gửi, khách có nút nhắn chủ sân. Chủ sân có nút nhắn khách trong danh sách đơn khi đơn gắn với một tài khoản khách. Các nút này mở đúng tài khoản cần trao đổi, giúp hai bên hỏi thông tin sân và thống nhất chi tiết buổi chơi.

Danh sách và tin nhắn tự làm mới mỗi hai giây. Mỗi cặp tài khoản giữ tối đa 10 tin nhắn gần nhất theo cơ chế hiện có. Danh sách đang hiển thị các tài khoản khác, chưa có chức năng gửi lời mời hoặc kết bạn. Giao diện ghi rõ đây là tin nhắn trực tiếp; chưa theo dõi trạng thái trực tuyến thật.

Phần hội thoại dịch vụ mẫu và trả lời tự động đã tắt trên các đường dẫn cũ. Chat trực tiếp giữa các tài khoản vẫn hoạt động; dữ liệu hội thoại cũ được giữ nguyên.

## 20. Hồ sơ và điều hướng

Trang hồ sơ hiển thị thông tin thật của tài khoản đang đăng nhập. Người dùng lưu được họ tên, số điện thoại, giới tính, ngày sinh và địa chỉ. Các thông tin này được giữ trong PostgreSQL khi tải trang hoặc đăng nhập lại. Email đăng nhập được giữ cố định.

Nút Lưu kiểm tra họ tên, số điện thoại, ngày sinh không ở tương lai và độ dài địa chỉ. Khi có lỗi, biểu mẫu giữ lại nội dung đang nhập và báo lý do. Khi thành công, tên hiển thị trong phiên đăng nhập được cập nhật. Nút Hủy thay đổi tải lại thông tin đã lưu. Mỗi tài khoản chỉ cập nhật hồ sơ của chính mình; biểu mẫu có mã bảo vệ và không cho tự đổi email hoặc vai trò.

Ảnh đại diện hiện hiển thị chữ cái đầu của họ tên; thời điểm tham gia lấy từ tài khoản thực tế. Người dùng có thanh điều hướng đến trang chủ, lịch hẹn, cộng đồng, chat, hồ sơ và thông báo. Tài khoản chủ sân có thêm lối vào khu vực quản lý.

Biểu tượng trên trang giới thiệu, hồ sơ, đặt sân, chat, Newsfeed và khu vực chủ sân dùng chung một bộ SVG nét mảnh, đồng màu với chữ. Các nút chỉ có biểu tượng có nhãn hỗ trợ đọc màn hình. Ảnh sân dùng chung một thư mục tài nguyên.

Khu vực chủ sân có các trang tổng quan, quản lý sân, đơn đặt sân, lịch trống và khóa giờ, khách hàng, đánh giá và thông báo. Người dùng có thể quay lại trang khách hàng hoặc đăng xuất.

## 21. Dữ liệu và các nguyên tắc chung

Các tài khoản, sân, đơn đặt sân, giờ khóa, lịch sử xử lý, thông báo, lịch hẹn, bài viết, bình luận và tin nhắn được lưu trong PostgreSQL. Tải lại trang không làm mất những dữ liệu đã lưu thành công.

Các thao tác mới về đặt sân, quản lý sân và thông báo kiểm tra phiên đăng nhập, quyền sở hữu và mã bảo vệ biểu mẫu. Khách không được thay danh tính bằng cách gửi một mã người dùng khác; chủ sân không được quản lý sân của tài khoản khác. Việc giữ chỗ được kiểm tra tại máy chủ và có ràng buộc chống trùng lịch trong database.

## 22. Những phần còn ở mức giao diện hoặc chưa triển khai

- Hồ sơ đã lưu được thông tin cá nhân; chưa hỗ trợ tải ảnh đại diện.
- Các thẻ theo môn trên trang giới thiệu dùng hình minh họa. Danh sách sân, giá và lịch trống sau đăng nhập lấy từ dữ liệu sân thực tế.
- Thuê gear, trang phục và huấn luyện viên đã tắt theo phạm vi sản phẩm hiện tại. Không có luồng tạo yêu cầu thuê, quản lý tồn kho hoặc bàn giao đồ.
- Chưa có đặt cọc, thanh toán trực tuyến, hoàn tiền hoặc đối soát thanh toán.
- Chưa có bán vé theo sức chứa cho gym và hồ bơi, lịch đặt lặp hàng tuần, danh sách chờ hoặc tự gợi ý sân thay thế.
- Chưa có check-in bằng mã QR, tự xác nhận khách đã đến, tự xử lý khách không đến hoặc tự hoàn thành đơn theo đồng hồ.
- Chưa có gửi nhắc lịch qua email, SMS hoặc ứng dụng bên ngoài.
- Chưa có trang quản trị riêng để tự cấp quyền chủ sân, kiểm duyệt bài viết hoặc quản lý toàn bộ người dùng.
- Khách chưa có màn hình đăng đánh giá mới; phần đánh giá hiện phục vụ đọc và phản hồi các đánh giá đã có.

## 23. Một ví dụ sử dụng tính năng tự động mới

Chủ sân đăng nhập, mở quản lý sân và bật tự xác nhận cho một sân pickleball. Sau đó, chủ sân khóa khoảng 14:00–16:00 ngày mai với lý do bảo trì.

Khách mở sân đó và chọn ngày mai. Khoảng 14:00–16:00 được hiển thị là đã khóa. Khách chọn 18:00–19:00 còn trống rồi gửi đơn. Hệ thống kiểm tra lại lịch, xác nhận và giữ chỗ ngay nếu vẫn hợp lệ. Cả khách và chủ sân nhận thông báo; đơn có nhãn hệ thống tự xác nhận và có lịch sử xử lý.

Nếu một khách khác đặt cùng khung giờ, hệ thống không xác nhận thêm một đơn chồng nhau. Nếu chủ sân muốn khóa 18:00–19:00 sau đó, hệ thống thông báo đơn đang bị ảnh hưởng và chưa tạo lịch khóa. Khi buổi chơi kết thúc và chủ sân xác nhận khách đã sử dụng sân, đơn mới chuyển sang hoàn thành và được tính vào thống kê doanh thu hoàn thành.
