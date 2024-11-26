
import models.io.upbound.aws.ec2.v1beta1 as v1beta1
import models.io.upbound.aws.ec2.v1beta2 as ec2v1beta2
import models.io.upbound.aws.rds.v1beta1 as rdsv1beta1
import models.io.upbound.aws.rds.v1beta2 as rdsv1beta2
import models.io.upbound.aws.rds.v1beta3 as rdsv1beta3
import models.io.upbound.aws.v1alpha1 as awsv1alpha1
import models.io.upbound.aws.v1beta1 as awsv1beta1
import models.io.upbound.azure.dbforpostgresql.v1beta1 as dbforpostgresqlv1beta1
import models.io.upbound.azure.dbforpostgresql.v1beta2 as dbforpostgresqlv1beta2
import models.io.upbound.azure.v1alpha1 as azurev1alpha1
import models.io.upbound.azure.v1beta1 as azurev1beta1
import models.io.upbound.gcp.sql.v1beta1 as sqlv1beta1
import models.io.upbound.gcp.sql.v1beta2 as sqlv1beta2
import models.io.upbound.gcp.v1alpha1 as gcpv1alpha1
import models.io.upbound.gcp.v1beta1 as gcpv1beta1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1
import models.live.devopstoolkit.v1alpha1 as devopstoolkitv1alpha1

oxr = option("params").oxr # observed composite resource
_ocds = option("params").ocds # observed composed resources
_dxr = option("params").dxr # desired composite resource
dcds = option("params").dcds # desired composed resources

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}

_region = "us-east-1"
if oxr.spec?.parameters?.region:
    _region = oxr.spec.parameters.region


_items = [
    v1beta1.InternetGateway {
        metadata = _metadata("gateway")
        spec.forProvider = v1beta1.Ec2AwsUpboundIoV1beta1InternetGatewaySpecForProvider{
            region = _region
            vpcIdSelector.matchControllerRef = True
        }
    },
    v1beta1.MainRouteTableAssociation {
        metadata = _metadata("mainRouteTableAssociation")
        spec.forProvider = v1beta1.Ec2AwsUpboundIoV1beta1MainRouteTableAssociationSpecForProvider{
            region = _region
            routeTableIdSelector.matchControllerRef = True
            vpcIdSelector.matchControllerRef = True
        }
    },
    v1beta1.RouteTable {
        metadata = _metadata("routeTable")
        spec.forProvider = v1beta1.Ec2AwsUpboundIoV1beta1RouteTableSpecForProvider{
            region = _region
            vpcIdSelector.matchControllerRef = True
        }
    },
    v1beta1.Route {
        metadata = _metadata("route")
        spec.forProvider = v1beta1.Ec2AwsUpboundIoV1beta1RouteSpecForProvider{
            region = _region
            routeTableIdSelector.matchControllerRef = True
            destinationCidrBlock = "0.0.0.0/0"
            gatewayIdSelector.matchControllerRef = True
        }
    },
    v1beta1.SecurityGroupRule {
        metadata = _metadata("securityGroupRule")
        spec.forProvider = v1beta1.Ec2AwsUpboundIoV1beta1SecurityGroupRuleSpecForProvider{
            region = _region
            description = "I am too lazy to write descriptions"
            type = "ingress"
            fromPort = 5432
            toPort = 5432
            protocol = "tcp"
            cidrBlocks = ["0.0.0.0/0"]
            securityGroupIdSelector.matchControllerRef = True
        }
    },
    v1beta1.SecurityGroup {
        metadata = _metadata("securityGroup")
        spec.forProvider = v1beta1.Ec2AwsUpboundIoV1beta1SecurityGroupSpecForProvider{
            region = _region
            description = "I am too lazy to write descriptions"
            vpcIdSelector.matchControllerRef = True
        }
    },
    v1beta1.VPC {
        metadata = _metadata("vpc")
        spec.forProvider = v1beta1.Ec2AwsUpboundIoV1beta1VPCSpecForProvider{
            region = _region
            cidrBlock = "11.0.0.0/16"
            enableDnsSupport = True
            enableDnsHostnames = True
        }
    },
    rdsv1beta1.SubnetGroup {
        metadata = _metadata("subnetgroup")
        spec.forProvider = rdsv1beta1.RdsAwsUpboundIoV1beta1SubnetGroupSpecForProvider{
            region = _region
            description = "I'm too lazy to write a good description"
            subnetIdSelector.matchControllerRef = True
        }
    },
    rdsv1beta2.Instance {
        metadata = _metadata("rdsinstance")
        spec.forProvider = rdsv1beta2.RdsAwsUpboundIoV1beta2InstanceSpecForProvider{
            region = _region
            dbSubnetGroupNameSelector.matchControllerRef = True
            vpcSecurityGroupIdSelector.matchControllerRef = True
            username = "masteruser"
            engine = "postgres"
            skipFinalSnapshot = True
            publiclyAccessible = True
            allocatedStorage = 200
            passwordSecretRef = rdsv1beta2.RdsAwsUpboundIoV1beta2InstanceSpecForProviderPasswordSecretRef {
                name = oxr.spec.id + "-password"
                namespace = oxr.spec.claimRef.namespace
                key = "password"
            }
            identifier = oxr.spec.id
            if oxr.spec.parameters.size == "small":
                instanceClass = "db.m5.large"
            elif oxr.spec.parameters.size == "medium":
                instanceClass = "db.m5.2xlarge"
            else:
                instanceClass = "db.m5.8xlarge"
            engineVersion = oxr.spec.parameters.version
        }
    },
    {
        **oxr
        if "rdsinstance" in _ocds:
            status.address = _ocds["rdsinstance"].Resource.status.atProvider.address
    }
]

items = _items
