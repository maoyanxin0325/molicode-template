<%
  def columns=tableDefine.columns
  def varDomainName=tableNameUtil.lowerCaseFirst(tableDefine.id)
  def urlPrefix=PubUtils.addStrBeforeSeparator(PubUtils.packageToPath(config.category),".")+varDomainName
%>
<template>
	<div class="add_molicode">
		<Modal class="addModal" v-model="showModal" :width="40" title="新增${tableDefine.cnname}" @on-ok="save" @on-cancel="cancel">
			<Form ref="formItems" :model="formData" :rules="formRules" :label-width="150" inline>
			<% columns.each{
				  def column=it;
				  if(column.getIsPK()){ return ;}
				  if(tableModel.isNotInList('addList',column.columnName)){return ;}%>
					<Row>
						<Col span="24">
							<Form-item label="${column.cnname}" prop="${column.dataName}" style="width: 90%">
								<% if(column.jspTag == 'SELECT'){%>
									<dict-select v-model="formData.${column.dataName}" :selectList="selectList" placeholder="请选择${column.cnname}" :clearable="true"></dict-select>
								<%} else if(column.jspTag == 'DATETIME'){%>
									<dict-date-picker v-model="formData.${column.dataName}" placeholder="请选择${column.cnname}" @change="dateChange"></dict-date-picker>
								<%} else if(column.jspTag == 'RADIO'){%>
									<dict-radio v-model="formData.${column.dataName}" :radioList="radioList"></dict-radio>
								<%} else if(column.jspTag == 'CHECKBOX'){%>
									<dict-checkbox v-model="formData.${column.dataName}" :checkboxList="checkboxList"></dict-checkbox>
								<%} else {%>
									<Input v-model="formData.${column.dataName}" :maxlength="${column.length}" :disabled="disableInput"></Input>
								<%}%>
							</Form-item>
						</Col>
					</Row><%}%>
			</Form>
			<div slot="footer">
				<Button type="default" @click="cancel">取消</Button>
				<Button type="primary" @click="save" :loading="loading"><Icon type="android-done"></Icon> 保存</Button>
			</div>
		</Modal>
	</div>
</template>

<script>
		import dictCheckbox from '@/components/molicode/DictCheckBox'
		import dictRadio from '@/components/molicode/DictRadio'
		import dictSelect from '@/components/molicode/DictSelect'
		import dictDatePicker from '@/components/molicode/DictDatePicker'
		import * as dictionary from '@/api/dictionary'
    var validateSet = {
<%
			def listSize=tableModel.listSize('addList');
		 	int i=0;
			columns.each{
			  def column=it;
			  if(tableModel.isNotInList('addList',column.columnName)){
				return ;
			  }
			  if(column.getIsPK()){
			  	i++;
				return ;
			  }
		    print "\t"+snippetTemplateUtil.getTemplate(column,'form_rule_item_vue');
		 	i++;
			if(i<listSize) println ',';
		}
		%>
    }
    var formData = {
<%
		 	i=0;
			columns.each{
			  def column=it;
			  if(tableModel.isNotInList('addList',column.columnName)){
				return ;
			  }
			  if(column.getIsPK()){
			  	i++;
				return ;
			  }
		    print """\t\t${column.dataName}: null"""
		 	i++;
			if(i<listSize) println ',';
		}
		%>
    }
    export default {
			  components: {
					dictSelect,
					dictRadio,
					dictCheckbox,
					dictDatePicker
				},
        data () {
            return {
								id: '0',
                formData: formData,
                formRules: validateSet,
               // formRules: constants.rules.${varDomainName}.add,
                showModal: false,
                loading: false,
								disableInput: false,
								selectList: [],
								radioList: [],
								checkboxList: []
            }
        },
        methods:{
						load (id) {
							this.loadSelect()
							if (id) {
								this.id = id
								api.getId({ id: id}).then(res => {
									if(res.data.success){
										this.formData = res.data.data
									}
								})
							}
							else {
								this.formData = formData
							}
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
									this.checkboxList = array
									this.radioList = array
								}
							})
						},
            save () {
                this.\$refs['formItems'].validate((valid) => {
                    if (!valid) {
											this.$Message.warning('请完善表单信息')
                    	return false
                		} else {

										}
								})
            },
						cancel () {
							this.$refs['formItems'].resetFields()
							this.showModal = false
						},
						dateChange (params) {
							Object.assign(this.formData, params)
						}
        }
    }
</script>
<style lang="less" scoped>
.add_molicode {
  display: inline-block;
	margin-left: 20px;
	.addModal {
		width: 80%;
	}
}
</style>
