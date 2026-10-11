# HTTP smoke check chỉ đọc

Không POST, không thay đổi database; không chạy migration/build/test. Không khẳng định WAR deployed khớp snapshot source.

Port 8080: open

GET http://127.0.0.1:8080/sportify/owner/access: HTTP 404
```text
    HTTP Status 404 – Not Found  body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}    HTTP Status 404 – Not Found    Type  Status Report   Message  The requested resource [&#47;sportify&#47;owner&#47;access] is not available   Description  The origin server did not find a current representation for the target resource or is not willing to disclose that one exists.   Apache Tomcat/11.0.25   
```

GET http://127.0.0.1:8080/sportify/owner/fields: HTTP 404
```text
    HTTP Status 404 – Not Found  body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}    HTTP Status 404 – Not Found    Type  Status Report   Message  The requested resource [&#47;sportify&#47;owner&#47;fields] is not available   Description  The origin server did not find a current representation for the target resource or is not willing to disclose that one exists.   Apache Tomcat/11.0.25   
```

GET http://127.0.0.1:8080/sportify/owner/reviews: HTTP 404
```text
    HTTP Status 404 – Not Found  body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}    HTTP Status 404 – Not Found    Type  Status Report   Message  The requested resource [&#47;sportify&#47;owner&#47;reviews] is not available   Description  The origin server did not find a current representation for the target resource or is not willing to disclose that one exists.   Apache Tomcat/11.0.25   
```

GET http://127.0.0.1:8080/sportify/chat: HTTP 404
```text
    HTTP Status 404 – Not Found  body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}    HTTP Status 404 – Not Found    Type  Status Report   Message  The requested resource [&#47;sportify&#47;chat] is not available   Description  The origin server did not find a current representation for the target resource or is not willing to disclose that one exists.   Apache Tomcat/11.0.25   
```

Port 8081: closed

Port 80: closed
