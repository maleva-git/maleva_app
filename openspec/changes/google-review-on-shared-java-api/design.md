# Design

`GoogleReviewApi(Dio, {companyId})` follows the other shared APIs.

The Google Review repository returns `List<Review>` built with `Review.fromJava`. Its save takes
typed values, which the bloc builds from the form; the shop name is upper-cased as before.
TransportDB's review form uses the same save.
