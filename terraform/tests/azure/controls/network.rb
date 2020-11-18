# load data from Terraform output
content = inspec.profile.file("terraform.json")
params = JSON.parse(content)

# store vnet in variable
VNET_ID = params['vnet_id']['value']
VNET_NAME = params['vnet_name']['value']
VNET_ADDRESS_SPACE = params['vnet_address_space']['value']
NGS_SECURITY_RULES =

control 'check-securityRules' do

    describe azure_generic_resource(group_name: 'spfarmstaging' ,
        name: 'spfarm-security-group-backend',
        type: 'Microsoft.Network/networkSecurityGroups') do

            its('name') {should cmp 'spfarm-security-group-backend'}
            its('location') {should cmp 'westus'}
            its('properties.securityRules.count') { should eq  3 }
    end
end
