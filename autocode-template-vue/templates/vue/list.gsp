<%
    def columns=tableDefine.columns
    def varDomainName=tableNameUtil.lowerCaseFirst(tableDefine.id)
    def urlPrefix=PubUtils.addStrBeforeSeparator(PubUtils.packageToPath(config.category),".")+varDomainName
%>
<template>
	<div> <% List<String> list=tableModel.getSearchKeyList();
            def listSize=list.size()
            list.each{
                def column=tableDefine.getColumnByColumnName(it);
                if("Select".equalsIgnoreCase(column.jspTag)) {%>
                    <dict-select v-model="formSearch.${column.dataName}" :selectList="selectList" placeholder="请选择${column.cnname}" :clearable="true"></dict-select>
                <%} else if ("DateTime".equalsIgnoreCase(column.jspTag) ){%>
                    <dict-date-picker v-model="formSearch.${column.dataName}" placeholder="请选择${column.cnname}" @change="dateChange"></dict-date-picker>
                <%} else {%>
                    <Input v-model="formSearch.${column.dataName}" placeholder="请输入${column.cnname}" style="width: 250px; margin-right: 20px;" />
                <%}%>
        <%}%>
        <div style="display: inline-block">
            <Button type="primary" @click="load" :loading="loading" style="margin-right: 10px">	
                <Icon :size="18" type="ios-search-outline"></Icon>查询
            </Button>
            <Button type="info" @click="add">
                <Icon :size="18" type="ios-add"></Icon>新增
            </Button>
        </div>
		<add ref="editModal" @refreshList="load()"></add>

		<Table border :columns="columns" :data="data" :loading="loading" style="margin-top: 30px">
            <template slot-scope="{ row, index }" slot="operateSlot">
                <Button type="primary" size="small" @click="edit(row)" style="margin-right: 10px">修改</Button>
                <Button type="error" size="small" @click="del(row)">删除</Button>
            </template>
        </Table>
		<div style="margin: 10px; overflow: hidden">
			<div style="float: right;">
				<Page :total="pc.total" :page-size="pc.pageSize" :current="pc.pageIndex" @on-page-size-change="pageCountChange" @on-change="pageNumChange" show-total show-elevator show-sizer></Page>
			</div>
		</div>
	</div>
</template>
<script>
    import add from './add.vue'
    import dictSelect from '@/components/molicode/DictSelect'
    import dictDatePicker from '@/components/molicode/DictDatePicker'
    import * as dictionary from '@/api/dictionary'
    import * as util from '@/libs/renderUtil'
    import constants from '@/constants/constants'
    import tableDefine from './tableDefine'
    import page from '@/components/mixin/page'

    export default {
        components: {
            add,
            dictSelect,
            dictDatePicker
        },
        mixins: [tableDefine, page],
        data (){
            return {
                data: [],
                selectList: []
            }
        },
        methods: {
            load () {
                let searchParam = util.searchParmasHandle(this.formSearch)
                searchParam['pageSize'] = this.pc.total
                searchParam['page'] = this.pc.currentPageNo
                console.log('查询参数:', searchParam)
                this.loadSelect()
                api.getList({
                    p: this.pageNum_select,
                    s: this.pageCount_select
                }).then(res => {
                    console.log(res)
                    if(res.data.success){
                        this.tableData = []
                        this.pc = res.data.pc
                    }
                })
            },
            loadSelect () {
                dictionary.getList({ dictType: 'sys_user_sex' }).then(res => {
                    if (res.data.code === 200) {
                        let array = []
                        res.data.rows.map(item => {
                            array.push({
                                value: item.dictValue,
                                label: item.dictLabel
                            })
                        })
                        this.selectList = array
                    }
                })
            },
            add () {
                this.$refs.editModal.showModal = true
                this.$refs.editModal.load()
            },
            edit (row) {
                this.$refs.editModal.showModal = true
                this.$refs.editModal.load(row.id)
            },
            del (row) {
                let params = { 'primaryKey': row.id }
                this.\$Modal.confirm({
                    title: '删除确认',
                    content: '您确定要执行删除操作吗？',
                    onOk: () => {

                    }
                })
            },
            dateChange (params) {
                Object.assign(this.formSearch, params)
            }
        }
    }
</script>
