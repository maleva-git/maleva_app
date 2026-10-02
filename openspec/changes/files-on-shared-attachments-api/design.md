# Design

| .NET call | Java |
|---|---|
| CommonApp/UploadFile (headers Comid, Id, FolderName, SubFolderName, FileName) | POST /api/attachments?companyRefId&recordId&folderName&subFolderName&mode=IMAGES_ONLY&keepOriginalName=true |
| CommonApp/FetchFiles?ImageDirectory=/Upload/c/f/id/sub/ | GET /api/attachments?... → names of png/jpg/jpeg files |
| CommonApp/DeleteFile (FileName header = /Upload/... path) | DELETE /api/attachments?...&paths=<name> |
| Common/FetchFile2 (job orders) | GET /api/attachments (folder `jobs order`) → `path`s |
| Common/UploadFile5 (job orders) | POST /api/attachments mode=PDF_AS_IMAGES keepOriginalName=false |
| Common/DeleteFile (job orders) | DELETE /api/attachments paths=<path> |

The stored name is predicted with the server's rule (base name with characters outside
`[A-Za-z0-9._-]` as `_`, leading `.`/`_` dropped, at most 100 characters, extension lower case) and
checked against the answer; a name the server did not store is a failure.

Paths stay `/Upload/<company>/...` (`file.upload.public-url-prefix`), so the screens that build
`<host>/Upload/...` image URLs are unchanged.
