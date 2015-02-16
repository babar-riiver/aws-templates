Templates and stuff for aws

- asp-net-cloudformation.template load-balanced OWIN application running on IIS. AMI used is created by packer using https://github.com/bernos/bakery/blob/master/win2012-r2-iis.json

Master template creates
- Load balancer
- IAM roles
- Blue and Green ASGs without scaling groups

Deployment template creates
- ASG launchconfig for current version
- Attach new launch config to inactive ASG
- Crank up min instances for inactive ASG
- Run tests against all instances
