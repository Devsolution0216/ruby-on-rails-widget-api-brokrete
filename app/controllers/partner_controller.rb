#app/controllers/partner_controller.rb
class PartnerController < ApplicationController
  after_action :allow_iframe

  def widget
    @_token = params[:_token]
    @google_store_url = "Google Store URL";
    @apple_store_url = "Apple Store URL";
    @html = '<div>
          <button class="button" onclick="alert(\'' + @google_store_url + '\')" style="background-color: white;color: black;text-align: center;font-size: 16px;margin: 4px 2px;opacity: 0.6;transition: 0.3s;display: inline-block;text-decoration: none;
              cursor: pointer;width: 250px;height: 62px;border-radius: 10px;border-width: 2px;border-color: black;">
            <div style="width:35px; height:60px;">
              <svg width="35" height="40" style="padding-left: 15px; padding-top: 9px;" viewBox="0 0 35 41" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M26.1071 33.1179L34.6934 28.5047L34.6936 9.99905L17.4714 0.745605L0.249207 9.99856L0.248965 28.5045L8.83529 33.1177L0.0780029 33.0278V40.8069L16.2179 40.8071L16.3327 34.2067C16.3332 34.1768 16.3325 34.1469 16.3325 34.1173C16.3347 33.7879 16.3206 33.4607 16.2902 33.1369C15.9855 29.8759 14.0768 26.9514 11.162 25.3852L8.60846 24.0133V14.4898L17.4714 9.72801L26.3341 14.49V24.0135L23.9104 25.3155C20.978 26.8911 19.0609 29.8441 18.7767 33.1369C18.7528 33.4128 18.7388 33.6909 18.7383 33.9712L18.738 34.1173L18.7238 40.8071L34.8639 40.8074L34.8641 33.0282L26.1071 33.1179Z" fill="#262B32"/>
              </svg>
            </div>
            <p style="margin-left: 50px; margin-top:-50px;">
              Order in <span style="color:green; font-weight:500;">real-time</span> on
            </p>
            <p align="center" style="width: 200px; margin-left: 40px; margin-top: -13px; font-weight:600;">BROKRETE</p>
          </button>
          <button class="button" onclick="alert(\'' + @apple_store_url + '\')" style="background-color: white;color: black;text-align: center;font-size: 16px;margin: 4px 2px;opacity: 0.6;transition: 0.3s;display: inline-block;text-decoration: none;
              cursor: pointer;width: 250px;height: 62px;border-radius: 10px;border-width: 2px;border-color: black;">
            <div style="width:35px; height:60px;">
              <svg width="35" height="40" style="padding-left: 15px; padding-top: 9px;" viewBox="0 0 35 41" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M26.1071 33.1179L34.6934 28.5047L34.6936 9.99905L17.4714 0.745605L0.249207 9.99856L0.248965 28.5045L8.83529 33.1177L0.0780029 33.0278V40.8069L16.2179 40.8071L16.3327 34.2067C16.3332 34.1768 16.3325 34.1469 16.3325 34.1173C16.3347 33.7879 16.3206 33.4607 16.2902 33.1369C15.9855 29.8759 14.0768 26.9514 11.162 25.3852L8.60846 24.0133V14.4898L17.4714 9.72801L26.3341 14.49V24.0135L23.9104 25.3155C20.978 26.8911 19.0609 29.8441 18.7767 33.1369C18.7528 33.4128 18.7388 33.6909 18.7383 33.9712L18.738 34.1173L18.7238 40.8071L34.8639 40.8074L34.8641 33.0282L26.1071 33.1179Z" fill="#262B32"/>
              </svg>
            </div>
            <p style="margin-left: 50px; margin-top:-50px;">
              <span style="color:green; font-weight:500;">Save 10%</span> ordering on
            </p>
            <p align="center" style="width: 200px; margin-left: 40px; margin-top: -13px; font-weight:600;">BROKRETE</p>
          </button>
        </div>'
    render :html => @html
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end