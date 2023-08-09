import '../../config.dart';

class API
{

  static const hostConnect="http://${Config.ipAddress}/Maintenance_Activity_API";
  static const hostConnectModules="$hostConnect/modules";


  //Submit Category
  static const submitCategory="$hostConnect/modules/addCategory.php";
//fetch Category Name to asset Screen
  static const fetchCategory="$hostConnect/modules/fetchCategoryName.php";

  //fetch Assets Name to asset Screen
  static const fetchAsset="$hostConnect/modules/fetchAsset.php";

//submit Asset
  static const submitAsset="$hostConnect/modules/addAsset.php";

//submit Worker
  static const submitWorker="$hostConnect/modules/addWorker.php";

//submit Activity
  static const submitActivity="$hostConnect/modules/addActivity.php";

  //submit login
  static const submitLogin="$hostConnect/modules/login.php";

  //fetch CategoryAsset
  static const fetchCategoryAsset="$hostConnect/modules/fetchCategoryAsset.php";

  //fetch data
  static const fetchData="$hostConnect/modules/fetchData.php";

  // //get workers
  // static const getWorkers="$hostConnect/modules/getWorkers.php";



  //Upload data
  static const uploadActivity="$hostConnect/modules/upload_activity.php";

  //generate reports
  static const generateReports="$hostConnect/modules/fetchFieldActivity.php";

  //Add supervisor
  static const addSupervisor="$hostConnect/modules/addSupervisor.php";



}