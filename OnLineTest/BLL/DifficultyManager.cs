﻿using System;
using System.Data;
using System.Collections.Generic;
using Maticsoft.Common;
using OnLineTest.Model;
namespace OnLineTest.BLL
{
	/// <summary>
	/// 试题的难度系数实例
	/// </summary>
	public partial class DifficultyManager
	{
		private readonly OnLineTest.DAL.DifficultyServers dal=new OnLineTest.DAL.DifficultyServers();
		public DifficultyManager()
		{}
		#region  BasicMethod

		/// <summary>
		/// 得到最大ID
		/// </summary>
		public int GetMaxId()
		{
			return dal.GetMaxId();
		}

		/// <summary>
		/// 是否存在该记录
		/// </summary>
		public bool Exists(int DifficultyId)
		{
			return dal.Exists(DifficultyId);
		}

		/// <summary>
		/// 增加一条数据
		/// </summary>
		public int  Add(OnLineTest.Model.Difficulty model)
		{
			return dal.Add(model);
		}

		/// <summary>
		/// 更新一条数据
		/// </summary>
		public bool Update(OnLineTest.Model.Difficulty model)
		{
			return dal.Update(model);
		}

		/// <summary>
		/// 删除一条数据
		/// </summary>
		public bool Delete(int DifficultyId)
		{
			
			return dal.Delete(DifficultyId);
		}
		/// <summary>
		/// 删除一条数据
		/// </summary>
		public bool DeleteList(string DifficultyIdlist )
		{
			return dal.DeleteList(DifficultyIdlist );
		}

		/// <summary>
		/// 得到一个对象实体
		/// </summary>
		public OnLineTest.Model.Difficulty GetModel(int DifficultyId)
		{
			
			return dal.GetModel(DifficultyId);
		}

		/// <summary>
		/// 得到一个对象实体，从缓存中
		/// </summary>
		public OnLineTest.Model.Difficulty GetModelByCache(int DifficultyId)
		{
			
			string CacheKey = "DifficultyModel-" + DifficultyId;
			object objModel = Maticsoft.Common.DataCache.GetCache(CacheKey);
			if (objModel == null)
			{
				try
				{
					objModel = dal.GetModel(DifficultyId);
					if (objModel != null)
					{
						int ModelCache = Maticsoft.Common.ConfigHelper.GetConfigInt("ModelCache");
						Maticsoft.Common.DataCache.SetCache(CacheKey, objModel, DateTime.Now.AddMinutes(ModelCache), TimeSpan.Zero);
					}
				}
				catch{}
			}
			return (OnLineTest.Model.Difficulty)objModel;
		}

		/// <summary>
		/// 获得数据列表
		/// </summary>
		public DataSet GetList(string strWhere)
		{
			return dal.GetList(strWhere);
		}
		/// <summary>
		/// 获得前几行数据
		/// </summary>
		public DataSet GetList(int Top,string strWhere,string filedOrder)
		{
			return dal.GetList(Top,strWhere,filedOrder);
		}
		/// <summary>
		/// 获得数据列表
		/// </summary>
		public List<OnLineTest.Model.Difficulty> GetModelList(string strWhere)
		{
			DataSet ds = dal.GetList(strWhere);
			return DataTableToList(ds.Tables[0]);
		}
		/// <summary>
		/// 获得数据列表
		/// </summary>
		public List<OnLineTest.Model.Difficulty> DataTableToList(DataTable dt)
		{
			List<OnLineTest.Model.Difficulty> modelList = new List<OnLineTest.Model.Difficulty>();
			int rowsCount = dt.Rows.Count;
			if (rowsCount > 0)
			{
				OnLineTest.Model.Difficulty model;
				for (int n = 0; n < rowsCount; n++)
				{
					model = dal.DataRowToModel(dt.Rows[n]);
					if (model != null)
					{
						modelList.Add(model);
					}
				}
			}
			return modelList;
		}

		/// <summary>
		/// 获得数据列表
		/// </summary>
		public DataSet GetAllList()
		{
			return GetList("");
		}

		/// <summary>
		/// 分页获取数据列表
		/// </summary>
		public int GetRecordCount(string strWhere)
		{
			return dal.GetRecordCount(strWhere);
		}
		/// <summary>
		/// 分页获取数据列表
		/// </summary>
		public DataSet GetListByPage(string strWhere, string orderby, int startIndex, int endIndex)
		{
			return dal.GetListByPage( strWhere,  orderby,  startIndex,  endIndex);
		}
		/// <summary>
		/// 分页获取数据列表
		/// </summary>
		//public DataSet GetList(int PageSize,int PageIndex,string strWhere)
		//{
			//return dal.GetList(PageSize,PageIndex,strWhere);
		//}

		#endregion  BasicMethod
		#region  ExtensionMethod

		#endregion  ExtensionMethod
	}
}

