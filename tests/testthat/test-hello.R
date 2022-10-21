test_that(
  desc = "hello world char test",
  code = {
    expect_true(object = inherits(x = hello(),
                                  what = "hello"))
  }
)
