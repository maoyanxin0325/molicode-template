<%
  def columns=tableDefine.columns
  def varDomainName=tableNameUtil.lowerCaseFirst(tableDefine.id)
  def urlPrefix=PubUtils.addStrBeforeSeparator(PubUtils.packageToPath(config.category),".")+varDomainName
%>
<template>
	<div class="add_molicode">
		<Button type="info"  @click="showModal = true">
			<Icon :size="18" type="ios-add"></Icon>新增
		</Button>
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
									<dict-select v-model="formData.${column.dataName}" placeholder="请选择${column.cnname}" :clearable="true"></dict-select>
								<%} else if(column.jspTag == 'DATETIME'){%>
									<dict-date-picker v-model="formData.${column.dataName}" placeholder="请选择${column.cnname}" @change="dateChange"></dict-date-picker>
								<%} else if(column.jspTag == 'RADIO'){%>
									 <RadioGroup v-model="formData.${column.dataName}">
											<Radio label="apple">
													<Icon type="logo-apple"></Icon>
													<span>Apple</span>
											</Radio>
									</RadioGroup>
								<%} else if(column.jspTag == 'CHECKBOX'){%>
									<CheckboxGroup v-model="formData.${column.dataName}">
											<Checkbox label="香蕉"></Checkbox>
											<Checkbox label="苹果"></Checkbox>
											<Checkbox label="西瓜"></Checkbox>
									</CheckboxGroup>
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
    import constants from '@/constants/constants.js'
    import requestUtils from '@/libs/axios.js'
		import dictCheckbox from '@/components/molicode/DictCheckBox'
		import dictRadio from '@/components/molicode/DictRadio'
		import dictSelect from '@/components/molicode/DictSelect'
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
					dictCheckbox
				},
        data () {
            return {
                formData: formData,
                formRules: validateSet,
               // formRules: constants.rules.${varDomainName}.add,
                showModal: false,
                loading: false,
                disableInput: false
            }
        },
        methods:{
            save: function () {
                this.\$refs['formItems'].validate((valid) => {
                    if (!valid) {
                    return false
                }
                requestUtils.postSubmit(this, constants.urls.${urlPrefix}.add, this.formData, function (data) {
                    this.\$Message.success({
                        content: '新增成功',
                        duration: 3
                    })
                    this.showModal = false
                    this.\$emit(constants.actions.common.refreshList)
                })
            })
            },
            'cancel': function () {
                this.\$refs['formItems'].resetFields()
                this.showModal = false
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
