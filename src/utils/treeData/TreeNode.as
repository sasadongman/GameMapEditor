package utils.treeData 
{
	/**
	 * 树节点，不含leaf
	 * @author Alex
	 */
	public class TreeNode 
	{
		//节点id
		public var id:String = "";
		//是否根节点
		public var isRoot:Boolean = false;
		public var isLeafFinished:Boolean = false;
		public var isBranchFinished:Boolean = false;
		//父节点
		public var parent:TreeNode;
		//直接子节点集合
		public var children:Vector.<TreeNode>;
		
		/**
		 * TreeNode构造函数
		 * @param	id
		 * @param	isLeafFinished = false
		 * @param	isBranchFinished = false
		 * @param	isRoot
		 */
		public function TreeNode(id:String = "", isLeafFinished:Boolean = false, isBranchFinished:Boolean = false, isRoot:Boolean = false):void
		{
			this.id = id;
			this.isLeafFinished = isLeafFinished;
			this.isBranchFinished = isBranchFinished;
			this.isRoot = isRoot;
			children = new Vector.<TreeNode>();
		}
		
		/**
		 * 添加子节点
		 * @param	node
		 */
		public function addChild(node:TreeNode):TreeNode
		{
			if (node == null) 
			{
				return null;
			}
			var sameNameNodeIndex:int = getChildIndex(node.id);
			if (sameNameNodeIndex != -1) 
			{
				throw new Error("添加的子节点重名！");
				return null;
			}
			children.push(node);
			node.parent = this;
			return node;
		}
		
		/**
		 * 根据属性添加子节点
		 * @param	id
		 * @param	isLeafFinished = false
		 * @param	isBranchFinished = false
		 * @return
		 */
		public function addChildByAttribute(id:String = "", isLeafFinished:Boolean = false, isBranchFinished:Boolean = false):TreeNode
		{
			var node:TreeNode = new TreeNode(id, isLeafFinished, isBranchFinished, false);
			return addChild(node);
		}
		
		/**
		 * 得到未完成分支处理的节点
		 * @return
		 */
		public function getBranchUnfinishedNode():TreeNode
		{
			for (var i:int = 0; i < children.length; i++) 
			{
				var childNode:TreeNode = children[i];
				if (childNode.isBranchFinished == false) 
				{
					return childNode;
				}
				//var childBranch:TreeNode = childNode.getBranchUnfinishedNode();
				//if (childBranch != null) 
				//{
					//return childBranch;
				//}
			}
			//返回null时外部对其设置isBranchFinished=true
			return null;
		}
		
		/**
		 * 得到节点，可以是多层的
		 * @param	idVector
		 * @return
		 */
		public function getNode(path:Vector.<String>):TreeNode
		{
			if (path == null) 
			{
				return null;
			}
			if (path.length == 0) 
			{
				path = null;
				return this;
			}
			var child:TreeNode = getChild(path.shift());
			if (child == null) 
			{
				return null;
			}
			return child.getNode(path);
		}
		
		/**
		 * 得到子节点
		 * @param	childId
		 * @return
		 */
		public function getChild(childId:String):TreeNode
		{
			var childIndex:int = getChildIndex(childId);
			if (childIndex == -1) 
			{
				return null;
			}
			else 
			{
				return children[childIndex];
			}
		}
		
		/**
		 * 得到子节点索引
		 * @param	childId
		 * @return
		 */
		public function getChildIndex(childId:String):int
		{
			for (var i:int = 0; i < children.length; i++) 
			{
				var curChild:TreeNode = children[i];
				if (curChild.id == childId) 
				{
					return i;
				}
			}
			return -1;
		}
		
		/**
		 * 得到路径组成
		 * @return
		 */
		public function getPathVector():Vector.<String>
		{
			var path:Vector.<String> = new Vector.<String>();
			var curNode:TreeNode = this;
			while (curNode.parent != null) 
			{
				path.unshift(curNode.id);
				curNode = curNode.parent;
			}
			path.unshift(curNode.id);
			return path;
		}
		/**
		 * 得到路径
		 * @return
		 */
		public function getPath():String
		{
			var vector:Vector.<String> = getPathVector();
			var path:String = vector.join("\\");
			return path;
		}
		
		/**
		 * 得到路径增强版
		 * @param	delim 分隔符
		 * @param	includeRoot 是否包含root
		 */
		public function getPathPro(delim:String = "/", includeRoot:Boolean = true):String
		{
			var vector:Vector.<String> = getPathVector();
			if (!includeRoot) 
			{
				vector.shift();
			}
			var path:String = vector.join(delim);
			return path;
		}
	}

}