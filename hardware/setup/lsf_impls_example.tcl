# Add or remove strategies in the following list, then:
# export LSF_IMPL_LIST=<path to this file>
# export OCACCEL_LSF_IMPL=TRUE
#
# You will start a new LSF run for each strategy listed below.
set impl_strategies { \
    Performance_Explore \
    Performance_ExplorePostRoutePhysOpt \
}

# list of available strategies as of vivado 2018.3
#
# Performance_Explore 
# Performance_ExplorePostRoutePhysOpt 
# Performance_ExploreWithRemap 
# Performance_WLBlockPlacement 
# Performance_WLBlockPlacementFanoutOpt 
# Performance_EarlyBlockPlacement 
# Performance_NetDelay_high 
# Performance_NetDelay_low 
# Performance_Retiming 
# Performance_ExtraTimingOpt 
# Performance_RefinePlacement 
# Performance_SpreadSLLs 
# Performance_BalanceSLLs 
# Performance_BalanceSLRs 
# Performance_HighUtilSLRs 
# Congestion_SpreadLogic_high 
# Congestion_SpreadLogic_medium 
# Congestion_SpreadLogic_low 
# Congestion_SSI_SpreadLogic_high 
# Congestion_SSI_SpreadLogic_low 

