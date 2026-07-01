# This is an example of a cloudwatch dashboard that takes the NetworkIn and
# NetworkOut metrics and sums them.

resource "aws_cloudwatch_dashboard" "network_io" {
  dashboard_name = "ec2-network-io"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          title  = "EC2 Network I/O",
          region = "eu-west-3",
          period = 300, # 5 minutes
          stat   = "Sum",
          metrics = [
            # m1: NetworkIn
            [{ "id" : "m1", "metricName" : "NetworkIn", "namespace" : "AWS/EC2", "dimensions" : { "InstanceId" : "i-1234567890abcdef0" }, "stat" : "Sum", "period" : 300 }],
            # m2: NetworkOut
            [{ "id" : "m2", "metricName" : "NetworkOut", "namespace" : "AWS/EC2", "dimensions" : { "InstanceId" : "i-1234567890abcdef0" }, "stat" : "Sum", "period" : 300 }],
            # Expression: m1 + m2
            [{ "id" : "e1", "expression" : "m1+m2", "label" : "Total Network I/O", "region" : "eu-west-3" }]
          ],
          view    = "timeSeries",
          stacked = false,
          yAxis = {
            left = { label = "Bytes", showUnits = true }
          }
        }
      }
    ]
  })
}
