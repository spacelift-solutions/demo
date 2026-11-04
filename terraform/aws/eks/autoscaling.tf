#---------------------------------------------------------------
# Node autoscaling
#---------------------------------------------------------------
# Two complementary mechanisms:
#
# 1. Cluster Autoscaler (below, through the blueprints add-ons module) adds
#    nodes when pods are Pending for lack of capacity and removes nodes that
#    sit underutilised. EKS tags the managed node group's Auto Scaling group
#    with `k8s.io/cluster-autoscaler/enabled` and
#    `k8s.io/cluster-autoscaler/<cluster>` so auto-discovery finds it.
#
# 2. A target-tracking policy on the same Auto Scaling group scales on
#    average CPU utilisation across the node group. It reacts to sustained
#    load on already-scheduled workloads, which Cluster Autoscaler ignores.
#
# Both operate within the node group's min_size/max_size. Cluster Autoscaler
# will not scale in a node that the policy just scaled out while its pods are
# still running, so the two do not thrash, but keep
# `node_cpu_target_utilization` well above Cluster Autoscaler's 50% scale-down
# threshold or the policy will add nodes that CA immediately judges idle.

resource "aws_autoscaling_policy" "node_cpu_target_tracking" {
  for_each = module.eks.eks_managed_node_groups

  name                   = "${each.key}-cpu-target-tracking"
  autoscaling_group_name = each.value.node_group_autoscaling_group_names[0]
  policy_type            = "TargetTrackingScaling"

  # Seconds the new instance's metrics are excluded from the aggregate after a
  # scale-out, so a fresh node joining the cluster does not trigger another.
  estimated_instance_warmup = var.node_cpu_scaling_warmup_seconds

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = var.node_cpu_target_utilization
    disable_scale_in = var.node_cpu_disable_scale_in
  }
}
