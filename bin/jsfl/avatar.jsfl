/**
 * 变量声明
 */
var doc;
//库
var lib;
//时间轴
var tl;
var targetFolder = "%targetFolder%";
var imagesInfo = %imagesInfo%;
/**
 * 程序执行
 */
//1.清除输出面板信息
fl.outputPanel.clear();
//2.执行
init();
//3.结束对话框
//alert("所有素材导入完成！");
/**
 * 功能函数
 */
//设置路径
function init()
{
	//创建新的fla文件
	doc = fl.createDocument("timeline");
	//指定库
	lib = doc.library;
	var as = "var isAnimation:Boolean = false;";
	as += "\nvar frameNum:int = 1;";
	as += "\nvar frameRate:int = 0;";
	as += "\nvar loop:Boolean = false;";
	
	var swf_url = "";
	for (var i = 0; i < imagesInfo.length; i++)
	{
		var wh_obj = imagesInfo[i];
		var imageFolder = wh_obj.folder;
		var imageName = wh_obj.name;
		var imageQuality = wh_obj.quality;
		//导入图片
		addImage(imageFolder + "/" + imageName, imageName, "frame0", imageQuality);
		var temp_as = as;
		temp_as += "\nvar positionInfo:Array = [{link:\"" + "frame0" + "\",x:" + wh_obj.x + ",y:" + wh_obj.y + ",time:" + wh_obj.time + "}];";
		doc.timelines[0].layers[0].frames[0].actionScript = temp_as;
		
		swf_url = targetFolder + "/" + imageName + ".swf";
		doc.exportSWF(swf_url, true);
		
		lib.deleteItem(imageName);
		
		FLfile.remove(imageFolder + "/" + imageName);
	}
	//关闭
	doc.close(false);
}
//添加图片资源到库
//filePath - 文件的磁盘路径，fileName - 文件名，imageLink - 文件链接
function addImage(filePath, fileName, imageLink, imageQuality)
{
	trace("filePath:" + filePath);
	trace("fileName:" + fileName);
	trace("imageLink:" + imageLink);
	//如果已存在，返回
	if(lib.itemExists(fileName))
	{
		trace("已存在:" + fileName);
		return;
	}
    doc.importFile(filePath, true);
    lib.selectItem(fileName);
    lib.setItemProperty('allowSmoothing', false);
	if(imageQuality == 100)
	{
		//无损压缩
		lib.setItemProperty('compressionType', 'lossless');
	}
	else
	{
		//JPEG压缩
		lib.setItemProperty('compressionType', 'photo');
		lib.setItemProperty('useImportedJPEGQuality', true);
		//自定义压缩质量
		lib.setItemProperty('quality', imageQuality);
	}
    //lib.moveToFolder(folderPath, fileName);
	lib.setItemProperty('linkageExportForAS', true);
	lib.setItemProperty('linkageExportForRS', false);
	lib.setItemProperty('linkageExportInFirstFrame', true);
	//lib.setItemProperty('linkageClassName', fileName);
	lib.setItemProperty('linkageClassName', imageLink);
}
//trace功能
function trace(message)
{
	//fl.outputPanel.trace(message);
	fl.trace(message);
}