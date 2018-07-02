//
//  URLManager.swift
//  cutup
//
//  Created by Star Developer on 3/6/17.
//  Copyright © 2017 Swyft. All rights reserved.
//

import UIKit

class URLManager: NSObject {
    
    class func getConvertToCrypto()->String {
        return CRYPTO_URL + "/ticker/"
    }
    
    class func getConvertToBtc()->String {
        return BASE_URL + "/tobtc"
    }
    
    class func getEndpointForLogin()->String {
        return BASE_URL + "/account/login"
    }
    
    class func getEndpointForForgetPassword()->String {
        return BASE_URL + "/account/forgotpassword"
    }
    
    class func getEndpointForRegisterUser()->String {
        return BASE_URL + "/account/registerUser"
    }
    
    class func getEndpointForTimeline()->String {
        return BASE_URL + "/profile/mytimeline/"
    }
    
    class func getEndpointForCustomersCutters()->String {
        return BASE_URL + "/User/GetUsersCutters/"
    }
    
    class func getEndpointForCustomersCuttersTimeLine()->String {
        return BASE_URL + "/User/GetUsersCuttersTimeLine/"
    }
    
    class func postEndPointForEditBarber()->String {
        return BASE_URL + "/Profile/UpdateCutterProfile"
    }
    
    class func getEndPointForGetUser()->String {
        return BASE_URL + "/Profile/GetUser/"
    }
    
    class func getEndPointForGetUsers()->String {
        return BASE_URL + "/Profile/GetUsers/"
    }
    
    /************** Images Related *****************/
    class func getEndPointForGetUserImages() -> String{
        return BASE_URL + "/images/GetUserImages/"
    }
    
    class func postEndPointForAddUserImage() -> String{
        return BASE_URL + "/images/AddUserImage/"
    }
    
    class func postEndPointForUploadImage() -> String{
        return BASE_URL + "/images/UploadImage/"
    }
    
    class func postEndPointForDeleteUserImage() -> String{
        return BASE_URL + "/images/DeleteUserImage/"
    }
    
    class func postEndPointForUpdateUserImage() -> String{
        return BASE_URL + "/images/UpdateUserImage/"
    }
    /***********************************************/
    
    class func postEndPointForEditCustomer()->String {
        return BASE_URL + "/User/UpdateUserProfile"
    }
    
    class func postEndPointForUploadProfilePicCustomer()->String {
        return BASE_URL + "/User/Updateprofilepic/"
    }
    
    class func postEndPointForSearchCutterByLocation() -> String {
        return BASE_URL + "/Search/SearchCutterByLocation"
    }
    class func postEndPointForCutterRating() -> String {
        return BASE_URL + "/User/RateCutter"
    }
    
    class func postEndPointForBarberStatus() -> String {
        
        return BASE_URL + "/Profile/UpdateStatus"
    }
    
    class func getEndpointForRequestCode()->String {
        return BASE_URL + "/Account/SendUserCodeTextMessage"
    }
    class func getEndpointForRequestMatchCode()->String {
        return BASE_URL + "/Account/VerifyCodeTextMessage"
    }
    class func getEndpointForUpdateCutterInstagramId()->String {
        return BASE_URL + "/Profile/AddUpdateCutterInstagramId"
    }
    class func getEndpointForGetCutterInstagramImages()->String {
        return BASE_URL + "/Profile/GetCutterInstagramPics/"
    }
    
    class func getInstagramCallBackURL()->String {
        return  "http://dev.cutup.io/api/account/instagramcallback"
    }
    
    class func updateEndPointForCutterBookmark()->String {
        return BASE_URL + "/User/ToggleCutterBookmark"
    }
    class func updateEndPointToggleImageLike()->String {
        return BASE_URL + "/User/ToggleImageLike"
    }
    class func updateEndPointForCutterBookmarkStatus()->String {
        return BASE_URL + "/User/GetBookmarkStatus"
    }
    class func getEndpointForChangePassword()->String {
        return BASE_URL + "/Account/ChangePassword"
    }
    class func getEndpointForGetLikeStatus()->String {
        return BASE_URL + "/User/GetLikeStatus"
    }
    class func getEndpointForGetImageDetails()->String {
        return BASE_URL + "/images/ImageDetails/"
    }
    class func getEndpointForGetCuttersDetails()->String {
        return BASE_URL + "/profile/allcutterdetails/"
    }
    
    
    
    // Added by Dan. 2017.06.22
    /*********************************** Payment api urls ***********************************/
    class func postEndpointForAddBankAccountInfo()->String {
        return BASE_URL + "/payment/AddBankAccountInfo"
    }
    
    class func getEndpointForGetBankAccountInfo()->String {
        return BASE_URL + "/payment/GetBankAccountInfo"
    }
    
    
    class func updateEndpointForAddUpdateCardInfo()->String {
        return BASE_URL + "/payment/AddUpdateCardInfo"
    }
    
    class func getEndpointForGetBankAccList()->String {
        return BASE_URL + "/payment/GetBankAccList"
    }
    
    class func getEndpointForGetCardInfoList()->String {
        return BASE_URL + "/payment/GetCardInfoList"
    }
    
    class func getEndpointForDeleteCardInfo()->String {
        return BASE_URL + "/payment/DeleteCardInfo"
    }
    
    class func postEndpointForProcessPayment()->String {
        return BASE_URL + "/payment/ProcessPayment"
    }
    
    class func postEndpointForCreateAppointment()->String {
        return BASE_URL + "/Appointment/CreateAppointment"
    }
    
    class func getEndpointForGetAppointments()->String {    //Get Appointments
        return BASE_URL + "/Appointment/GetAppointments"
    }
    
    class func getEndpointForChangeAppointmentStatus()->String {    //Change Appointment Status
        return BASE_URL + "/Appointment/ChangeAppointmentStatus"
    }
    
    class func getEndpointForFinishAppoitment()->String {    //Change Appointment Status
        return BASE_URL + "/Appointment/FinishAppointment"
    }
    // End of 'Payment api urls' *************************************************************
    
    /*********************************** Beacon api urls ***********************************/
    class func postRequestInstaBook()->String {
        return BASE_URL + "/instaBook/RequestInstaBook"
    }
    
    class func postActiveInstaBook()->String {
        return BASE_URL + "/instaBook/ActiveInstaBook"
    }
    
    class func getRequestInstaBookInfo()->String {
        return BASE_URL + "/instaBook/RequestInstaBookInfo"
    }
    
    class func getActiveRequestInstaBookInfos()->String {
        return BASE_URL + "/instaBook/GetActiveRequestInstaBookInfos"
    }
    
    class func postResponseInstaBook()->String {
        return BASE_URL + "/instaBook/ResponseInstaBook"
    }
    
    class func getResponseInstaBookInfo()->String {
        return BASE_URL + "/instaBook/ResponseInstaBookInfo"
    }
    
    class func postRequestInstaBookPhotos()->String {
        return BASE_URL + "/instaBook/RequestInstaBookPhotos/"
    }
    /***************************************************************************************/
    
    /********************************** Profile api urls ***********************************/
    class func getCutterServices()->String {
        return BASE_URL + "/Profile/CutterServices/"
    }
    
    class func postCutterService()->String {
        return BASE_URL + "/Profile/PostCutterService/"
    }
    
    class func delCutterService()->String {
        return BASE_URL + "/Profile/DelCutterService/"
    }
    /***************************************************************************************/
    
    /********************************** Cutter hour api urls ***********************************/
    class func getEndPointForGetCutterHour()->String {
        return BASE_URL + "/Profile/GetCutterHour/"
    }
    class func getEndPointForSaveCutterHour()->String {
        return BASE_URL + "/Profile/SaveCutterHour/"
    }
    /***************************************************************************************/
}




