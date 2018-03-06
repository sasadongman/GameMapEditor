package modules.CardBatchTool 
{
	import display.ResourceBitmap;
	import morn.CardViewUI;
	import morn.core.components.Clip;
	import morn.core.handlers.Handler;
	import smh.model.resource.staticConfig.txt.type_card;
	import smh.model.resource.staticConfig.txt.type_quality;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class CardView extends CardViewUI 
	{
		private var _card_bm:ResourceBitmap;
		private var _card_up_bm:ResourceBitmap;
		private var _handler:Handler;
		private var _id:int;
		public function CardView() 
		{
			super();
			_card_bm = new ResourceBitmap();
			_card_bm.handler = new Handler(loadCompleteHandle, [false]);
			card_box.addChild(_card_bm);
			_card_up_bm = new ResourceBitmap();
			_card_up_bm.handler = new Handler(loadCompleteHandle, [true]);
			card_up_box.addChild(_card_up_bm);
			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
		
		/**
		 * 设置卡牌id
		 * @param	id
		 * @param	folder
		 */
		public function setData(id:int, folder:String):void
		{
			_id = id;
			//
			var _type_card:type_card = GlobalConst.staticConfigDataBase.getData(id, type_card);
			var _type_quality:type_quality = GlobalConst.staticConfigDataBase.getData((_type_card.quality), type_quality);
			name_label.text = _type_card.name;
			introduceInfo_label.text = _type_card.decs;
			race_clip.index = _type_card.race - 1;
			switch (_type_card.quality) 
			{
				case 4:
				case 5:
					border_clip.index = 1;
				break;
				case 6:
				case 7:
					border_clip.index = 2;
				break;
				case 8:
					border_clip.index = 3;
				break;
				default:
					border_clip.index = 0;
			}
			var i:int;
			var starCount:int = 0;
			var star_clip:Clip;
			for (i = 1; i <= _type_quality.star_number; i++)
			{
				star_clip = star_box.getChildByName("star" + i + "_clip") as Clip;
				star_clip.index = 0;
				starCount ++;
			}
			for (i = _type_quality.star_number + 1; i <= 5; i++)
			{
				star_clip = star_box.getChildByName("star" + i + "_clip") as Clip;
				star_clip.index = 2;
			}
			star_box.x = 185 - starCount * 12;
			
			_card_bm.clear();
			_card_up_bm.clear();
			
			_curLoadTimes = 0;
			var key:String;
			var url:String;
			key = "" + (id % 100000);
			url = folder + "\\" + key + ".png";
			_needLoadTimes = 1;
			_card_bm.setResource(url);
			if (_type_card.quality == 6 || _type_card.quality == 7)
			{
				key += "a";
				url = folder + "\\" + key + ".png";
				_needLoadTimes = 2;
				_card_up_bm.setResource(url);
			}
		}
		
		private var _needLoadTimes:int;
		private var _curLoadTimes:int;
		private function loadCompleteHandle(isUp:Boolean):void
		{
			_curLoadTimes += 1;
			if (_curLoadTimes >= _needLoadTimes) 
			{
				_handler.executeWith([_id]);
			}
		}
		
		public function set handler(value:Handler):void 
		{
			_handler = value;
		}
	}
}