/**
 * 变量声明
 */
var doc;
//库
var lib;
//时间轴
var tl;
//选择素材所在文件夹
var nativePath = "%nativePath%";
var nativeFolderName = "%nativeFolderName%";
var swfFolder = "%swfFolder%";
var imageQuality = %imageQuality%;
var isAnimation = %isAnimation%;
var frameNum = %frameNum%;
var frameRate = %frameRate%;
var loop = %loop%;
var blend = "%blend%";
//[{n:"name",x:100,y:100},{n:"name",x:100,y:100}]
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
	//var pUri = FLfile.platformPathToURI(tempFolderUrl);
	//var pPath = decodeURI(pUri);
	//创建新的fla文件
	doc = fl.createDocument("timeline");
	//指定库
	lib = doc.library;
	var as = "var isAnimation:Boolean = " + isAnimation + ";";
	if(isAnimation)
	{
		as += "\nvar frameNum:int = " + frameNum + ";";
		as += "\nvar frameRate:int = " + frameRate + ";";
	}
	else
	{
		as += "\nvar frameNum:int = 1;";
		as += "\nvar frameRate:int = 0;";
	}
	as += "\nvar loop:Boolean = " + loop + ";";
	as += "\nvar blend:String = \"" + blend + "\";";
	//var positionInfo_arr = [];
	var swf_url = "";
	for (var i = 0; i < imagesInfo.length; i++)
	{
		var wh_obj = imagesInfo[i];
		var imageName = wh_obj.n;
		if(isAnimation)
		{
			var temp_str = "";
			if (imageName != "")
			{
				//导入图片
				//addImage(nativePath + "/" + imageName, imageName, "frame" + i);
				addImage(nativePath + "/" + imageName, imageName, "frame" + imageName);
				//var temp_str = "{link:\"" + "frame" + i + "\",x:" + wh_obj.x + ",y:" + wh_obj.y + ",time:" + wh_obj.time + "}";
				temp_str = "{link:\"" + "frame" + imageName + "\",x:" + wh_obj.x + ",y:" + wh_obj.y + ",time:" + wh_obj.time + "}";
			}
			else
			{
				temp_str = "{link:\"" + "" + "\",x:" + wh_obj.x + ",y:" + wh_obj.y + ",time:" + wh_obj.time + "}";
			}
			if(i == 0)
			{
				temp_str = "\nvar positionInfo:Array = [" + temp_str;
				if(i == imagesInfo.length - 1)
				{
					temp_str += "];";
				}
			}
			else
			{
				temp_str = "," + temp_str;
				if(i == imagesInfo.length - 1)
				{
					temp_str += "];";
				}
			}
			as += temp_str;
			//positionInfo_arr.push("{link:\"" + "frame" + i + "\",x:" + wh_obj.x + ",y:" + wh_obj.y + "}");
		}
		else
		{
			//导入图片
			addImage(nativePath + "/" + imageName, imageName, "frame0");
			
			var temp_as = as;
			temp_as += "\nvar positionInfo:Array = [{link:\"" + "frame0" + "\",x:" + wh_obj.x + ",y:" + wh_obj.y + ",time:" + wh_obj.time + "}];";
			doc.timelines[0].layers[0].frames[0].actionScript = temp_as;
			
			swf_url = swfFolder + "/" + imageName + ".swf";
			doc.exportSWF(swf_url, true);
			
			lib.deleteItem(imageName);
			
			FLfile.remove(nativePath + "/" + imageName);
		}
	}
	if (isAnimation)
	{
		for (var i = 0; i < imagesInfo.length; i++)
		{
			wh_obj = imagesInfo[i];
			imageName = wh_obj.n;
			if (imageName != "")
			{
				FLfile.remove(nativePath + "/" + imageName);
			}
		}
		//舞台第一帧加入as代码
		//var as = doc.timelines[0].layers[0].frames[0].actionScript;
		//as = "import flash.system.Security;";
		//as += "\nSecurity.allowDomain(\"*\");";
		//as += "\nvar animationDetailXml:XML = \n" + animationDetailXml.toString();
		
		//as += "\nvar positionInfo:Array = [" + positionInfo_arr.split(",") + "];";
		doc.timelines[0].layers[0].frames[0].actionScript = as;
		
		//fl.saveDocument(doc, swfFolder + "/package.fla");
		var swf_url = swfFolder + "/" + nativeFolderName + ".swf";
		doc.exportSWF(swf_url, true);
	}
	//关闭
	doc.close(false);
}
//添加图片资源到库
//filePath - 文件的磁盘路径，fileName - 文件名，imageLink - 文件链接
function addImage(filePath, fileName, imageLink)
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
	//无损压缩
    //lib.setItemProperty('compressionType', 'lossless');
	//JPEG压缩
    lib.setItemProperty('compressionType', 'photo');
    lib.setItemProperty('useImportedJPEGQuality', true);
	//自定义压缩质量
    lib.setItemProperty('quality', imageQuality);
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