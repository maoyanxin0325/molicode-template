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
			<Form ref="formItems" :model="formItems" :rules="formRules" :label-width="150" inline>
			<% columns.each{
				  def column=it;
				  if(column.getIsPK()){
					return ;
				  }
				  if(tableModel.isNotInList('addList',column.columnName)){
					return ;
				  }
			%>
				<Row>
					<Col span="24">
					<Form-item label="${column.cnname}" prop="${column.dataName}" style="width: 90%">
						<Input v-model="formItems.${column.dataName}" :maxlength="${column.length}" :disabled="disableInput"></Input>
					</Form-item>
				</Col>
				</Row>
				<%
				}
				%>
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

    var formItems = {
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
        data () {
            return {
                formItems: formItems,
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
                requestUtils.postSubmit(this, constants.urls.${urlPrefix}.add, this.formItems, function (data) {
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
