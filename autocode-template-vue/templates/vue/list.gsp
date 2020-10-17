<%
    def columns=tableDefine.columns
    def varDomainName=tableNameUtil.lowerCaseFirst(tableDefine.id)
    def urlPrefix=PubUtils.addStrBeforeSeparator(PubUtils.packageToPath(config.category),".")+varDomainName

%>
<template>
	<div>
        <%
            List<String> list=tableModel.getSearchKeyList();
            def listSize=list.size()
            list.each{
                def column=tableDefine.getColumnByColumnName(it);
                if("Select".equalsIgnoreCase(column.jspTag)) {%>
                    <dict-select v-model="formSearch.${column.dataName}" placeholder="请选择${column.cnname}" :clearable="true"></dict-select>
                <%}else if("DateTime".equalsIgnoreCase(column.jspTag) ){%>
                    <dict-date-picker v-model="formSearch.${column.dataName}" placeholder="请选择${column.cnname}"></dict-date-picker>
                <%} else {%>
                    <Input v-model="formSearch.${column.dataName}" placeholder="请输入${column.cnname}" style="width: 250px; margin-right: 20px;" />
                <%
                }
            }
        %>
        <div style="display: inline-block">
            <Button type="primary" @click="loadPageNoChange(1)" :loading="loading">	
                <Icon :size="18" type="ios-search-outline"></Icon>查询
            </Button>
            <add v-on:refreshList="loadData()"></add>
        </div>
		<edit ref="editModal" v-on:refreshList="loadData()"></edit>

		<Table border :columns="columns" :data="data.list" :loading="loading" style="margin-top: 30px">
            <template slot-scope="{ row, index }" slot="operateSlot">
                <Button type="primary" size="small" @click="editItem(row)" style="margin-right: 10px">修改</Button>
                <Button type="error" size="small" @click="doDelete(row)">删除</Button>
            </template>
        </Table>
		<div style="margin: 10px;overflow: hidden">
			<div style="float: right;">
				<Page :total="data.pc.totalCount" :pageSize="data.pc.pageSize"
					  :current="data.pc.currentPageNo" @on-page-size-change="loadPageSizeChange"
					  @on-change="loadPageNoChange" show-total show-elevator show-sizer></Page>
			</div>
		</div>
	</div>
</template>
<script>
    import add from './add.vue'
    import edit from './edit.vue'
    import dictSelect from '@/components/molicode/DictSelect'
    import dictCheckbox from '@/components/molicode/DictCheckBox'
    import dictDatePicker from '@/components/molicode/DictDatePicker'
    import dictRadio from '@/components/molicode/DictRadio'
    import tableDefine from './tableDefine.js'
    import requestUtils from '@/libs/axios.js'
    import constants from '@/constants/constants'

    export default {
        components: {
            add,
            edit,
            dictSelect,
            dictCheckbox,
            dictDatePicker,
            dictRadio
        },
        mixins: [tableDefine],
        data (){
            return {
                data: {
                    list:[],
                    pc:{}
                }
            }
        }
        methods: {
            loadPageSizeChange(pageSize) {
                this.data.pc.pageSize = pageSize
                this.loadData()
            },
            loadPageNoChange(pageNo) {
                this.data.pc.currentPageNo = pageNo
                this.loadData()
            },
            loadData() {
                var _this = this
                var searchParam = requestUtils.serializeObject(this.formSearch, true, true)
                searchParam['pageSize'] = _this.data.pc.pageSize
                searchParam['page'] = _this.data.pc.currentPageNo
                requestUtils.postSubmit(_this, constants.urls.${urlPrefix}.list, searchParam, (data) => {
                    _this.data.list = data.value
                    _this.data.pc = data.pageQuery
                }, null, true)
            },
            editItem: function (item) {
                this.\$refs.editModal.editItem(item)
            },
            doDelete(row) {
                var _this = this
                var params = { 'primaryKey': row.id }
                this.\$Modal.confirm({
                    title: '删除确认',
                    content: '您确定要执行删除操作吗？',
                    onOk: function() {
                        requestUtils.postSubmit(this, constants.urls.${urlPrefix}.delete, params, function (data) {
                            _this.\$Message.success({
                                content: '删除成功',
                                duration: 3
                            })
                            _this.loadData()
                        })
                    }
                })
            }
        }
    }
</script>
