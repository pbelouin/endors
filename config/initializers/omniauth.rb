Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin, '781jipdoawy8jv', 'f4RbE983r62fmRdQ'
  provider :github, 'd1b992a2da973848bc9a', '8566572173d9035a881814a6566c1b9209e5c7c0'
end