CloudFormation {
	Description ""

	Parameter("BuildNumber") {
		String		
	}

	Parameter("WebServerPort") {
		String
		Description "The TCP port the web server will listen on"
		Default "80"
	}

	LoadBalancer("WebLoadBalancer") {
		AvailabilityZones FnGetAZs("")
		Listeners [{
			:LoadBalancerPort => "80",
			:InstancePort 	  => Ref("WebServerPort"),
			:Protocol 		  => "HTTP"
		}]
	}

	AutoScalingGroup("WebServerScalingGroup") {
		AvailabilityZones FnGetAZs("")
		LaunchConfigurationName Ref("WebServerLaunchConfiguration")
		LoadBalancerNames Ref("WebLoadBalancer")
		MinSize 2
		MaxSize 4
		CreationPolicy("ResourceSignal", { 
			:Count => 2, 
			:Timeout => "PT20M" 
		})
	}

	LaunchConfiguration("WebServerLaunchConfiguration") {
		ImageId "ami-9dd8afa7"
		KeyName  "brendan-keypair"
		InstanceType "m1.small"
		SecurityGroups [Ref("InstanceSecurityGroup")]
		IamInstanceProfile "arn:aws:iam::xxx:instance-profile/xxx"
		UserData FnBase64(FnFormat(IO.read('script.txt'), {
			:StackId => Ref("AWS::StackId"),
			:Region  => Ref("AWS::Region")
		}))

		Metadata("BuildNumber", Ref("BuildNumber"))
		Metadata("AWS::CloudFormation::Authentication", {
			:default => {
				:type 	  => "s3",
				:buckets  => ["dotnet-cf-deployment-packages"],
				:roleName => "DeployerRole"
			}
		})
		Metadata("AWS::CloudFormation::Init", {
			:config => {
				:sources => {
					"c:\\inetpub\\test" => FnJoin("", [
						"https://dotnet-cf-deployment-packages.s3.amazonaws.com/dist-", 
						Ref("BuildNumber"), 
						".zip"
					])
				}
			}
		})
	}

	EC2_SecurityGroup("InstanceSecurityGroup") {
		Type "AWS::EC2::SecurityGroup"		
		GroupDescription "Enable HTTP from the load balancer only"
		SecurityGroupIngress [{
			:IpProtocol 				=> "tcp",
			:FromPort   				=> Ref("WebServerPort"),
			:ToPort     				=> Ref("WebServerPort"),
			:SourceSecurityGroupOwnerId => FnGetAtt("WebLoadBalancer", "SourceSecurityGroup.OwnerAlias"),
			:SourceSecurityGroupName    => FnGetAtt("WebLoadBalancer", "SourceSecurityGroup.GroupName")
		}]

	}
	
}