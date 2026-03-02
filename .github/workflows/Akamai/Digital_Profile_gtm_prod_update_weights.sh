#!/bin/bash
# Akamai GTM Traffic Weight Update Script for Loyalty Domains
# Reads EAST_WEIGHT and WEST_WEIGHT from environment variables (set by GitHub Actions).
# Validates both are integers 0-100 and sum to exactly 100.
# Allowed combinations: East=100/West=0, West=100/East=0, or any split totaling 100.
set -euo pipefail

# ---------------------------------------------------------------------------
# Input validation
# ---------------------------------------------------------------------------
east="${EAST_WEIGHT:?ERROR: EAST_WEIGHT env variable is not set}"
west="${WEST_WEIGHT:?ERROR: WEST_WEIGHT env variable is not set}"

# Must be integers
if ! [[ "$east" =~ ^[0-9]+$ ]] || ! [[ "$west" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Weights must be integers. Got EAST_WEIGHT='$east', WEST_WEIGHT='$west'"
    exit 1
fi

# Must be in range 0-100
if (( east < 0 || east > 100 || west < 0 || west > 100 )); then
    echo "ERROR: Weights must be between 0 and 100. Got EAST=$east, WEST=$west"
    exit 1
fi

# Must sum to exactly 100
total=$((east + west))
if (( total != 100 )); then
    echo "ERROR: East ($east) + West ($west) = $total. Total must equal 100."
    exit 1
fi

# Log the traffic mode
if (( east == 100 && west == 0 )); then
    echo "Mode: East 100% / West 0% (full east)"
elif (( east == 0 && west == 100 )); then
    echo "Mode: East 0% / West 100% (full west)"
else
    echo "Mode: East ${east}% / West ${west}% (split traffic)"
fi

echo "Validated: East=${east}% + West=${west}% = 100%"
echo

# ---------------------------------------------------------------------------
# Datacenter ID Lookup Table (Global Variables)
# ---------------------------------------------------------------------------
# Domain                              | East DC | West DC
# ------------------------------------|---------|--------
# loyalty-account-management-aa       |  3134   |  3133
# loyalty-corporate-entity-aa         |     1   |     2
# loyalty-customerprofile-aa          |     1   |     2
# loyalty-enrollment-service-aa       |     2   |     3
# loyalty-login-authsvc-aa            |     1   |     2
# loyalty-login-dataservice-aa        |     2   |     3
# loyalty-login-messagingsvc-aa       |     1   |     2
# loyalty-pnrsvc-aa                   |     1   |     2
# loyalty-premerge-service-aa         |     2   |     3
# loyalty-profile-aa                  |  3132   |  3135
# ---------------------------------------------------------------------------

# Account Management
ACCT_MGMT_EAST=3134
ACCT_MGMT_WEST=3133

# Corporate Entity
CORP_ENTITY_EAST=1
CORP_ENTITY_WEST=2

# Customer Profile
CUST_PROFILE_EAST=1
CUST_PROFILE_WEST=2

# Enrollment Service
ENROLLMENT_EAST=2
ENROLLMENT_WEST=3

# Login AuthSvc
AUTH_SVC_EAST=1
AUTH_SVC_WEST=2

# Login DataService
DATA_SVC_EAST=2
DATA_SVC_WEST=3

# Login MessagingSvc
MSG_SVC_EAST=1
MSG_SVC_WEST=2

# PNR Svc
PNR_SVC_EAST=1
PNR_SVC_WEST=2

# Premerge Service
PREMERGE_EAST=2
PREMERGE_WEST=3

# Profile
PROFILE_EAST=3132
PROFILE_WEST=3135

# ---------------------------------------------------------------------------
# Helper function to update a property using lookup variables
# ---------------------------------------------------------------------------
update_property() {
    local domain="$1"
    local property="$2"
    local east_dc="$3"
    local west_dc="$4"
    akamai gtm --section gtm update-property "${domain}" "${property}" \
        --target "{\"datacenterId\": ${east_dc},\"weight\":${east},\"enabled\":true}" \
        --target "{\"datacenterId\": ${west_dc},\"weight\":${west},\"enabled\":true}" \
        --verbose
}

# ===========================================================================
# Update all domains using lookup table variables
# ===========================================================================

echo " ##################################################"
echo " ####   Loyalty Account Management (DC ${ACCT_MGMT_EAST}=east, ${ACCT_MGMT_WEST}=west)  ####"
echo " ##################################################"
echo
update_property loyalty-account-management-aa.com.akadns.net prod              "$ACCT_MGMT_EAST" "$ACCT_MGMT_WEST"
update_property loyalty-account-management-aa.com.akadns.net prod-event-router "$ACCT_MGMT_EAST" "$ACCT_MGMT_WEST"
update_property loyalty-account-management-aa.com.akadns.net prod-sabre-ci-broker "$ACCT_MGMT_EAST" "$ACCT_MGMT_WEST"
# --- Original hardcoded lines ---
# akamai gtm --section gtm update-property loyalty-account-management-aa.com.akadns.net prod --target '{"datacenterId": '3134',"weight":'$east',"enabled":true}' --target '{"datacenterId": '3133',"weight":'$west',"enabled":true}' --verbose
# akamai gtm --section gtm update-property loyalty-account-management-aa.com.akadns.net prod-event-router --target '{"datacenterId": '3134',"weight":'$east',"enabled":true}' --target '{"datacenterId": '3133',"weight":'$west',"enabled":true}' --verbose
# akamai gtm --section gtm update-property loyalty-account-management-aa.com.akadns.net prod-sabre-ci-broker --target '{"datacenterId": '3134',"weight":'$east',"enabled":true}' --target '{"datacenterId": '3133',"weight":'$west',"enabled":true}' --verbose

echo " ##################################################"
echo " ####   Loyalty Corporate Entity (DC ${CORP_ENTITY_EAST}=east, ${CORP_ENTITY_WEST}=west)  ####"
echo " ##################################################"
echo
update_property loyalty-corporate-entity-aa.com.akadns.net prod "$CORP_ENTITY_EAST" "$CORP_ENTITY_WEST"
# --- Original hardcoded line ---
# akamai gtm --section gtm update-property loyalty-corporate-entity-aa.com.akadns.net prod --target '{"datacenterId": '1',"weight":'$east',"enabled":true}' --target '{"datacenterId": '2',"weight":'$west',"enabled":true}' --verbose

echo " ##################################################"
echo " ####   Loyalty Customer Profile (DC ${CUST_PROFILE_EAST}=east, ${CUST_PROFILE_WEST}=west)  ####"
echo " ##################################################"
echo
update_property loyalty-customerprofile-aa.com.akadns.net azure-prod "$CUST_PROFILE_EAST" "$CUST_PROFILE_WEST"
# --- Original hardcoded line ---
# akamai gtm --section gtm update-property loyalty-customerprofile-aa.com.akadns.net azure-prod --target '{"datacenterId": '1',"weight":'$east',"enabled":true}' --target '{"datacenterId": '2',"weight":'$west',"enabled":true}' --verbose

echo " ##################################################"
echo " ####   Loyalty Enrollment Service (DC ${ENROLLMENT_EAST}=east, ${ENROLLMENT_WEST}=west)  ####"
echo " ##################################################"
echo
update_property loyalty-enrollment-service-aa.com.akadns.net prod "$ENROLLMENT_EAST" "$ENROLLMENT_WEST"
# --- Original hardcoded line ---
# akamai gtm --section gtm update-property loyalty-enrollment-service-aa.com.akadns.net prod --target '{"datacenterId": '2',"weight":'$east',"enabled":true}' --target '{"datacenterId": '3',"weight":'$west',"enabled":true}' --verbose

echo " ##################################################"
echo " ####   Loyalty Login AuthSvc (DC ${AUTH_SVC_EAST}=east, ${AUTH_SVC_WEST}=west)  ####"
echo " ##################################################"
echo
update_property loyalty-login-authsvc-aa.com.akadns.net prod "$AUTH_SVC_EAST" "$AUTH_SVC_WEST"
# --- Original hardcoded line ---
# akamai gtm --section gtm update-property loyalty-login-authsvc-aa.com.akadns.net prod --target '{"datacenterId": '1',"weight":'$east',"enabled":true}' --target '{"datacenterId": '2',"weight":'$west',"enabled":true}' --verbose

echo " ##################################################"
echo " ####   Loyalty Login DataService (DC ${DATA_SVC_EAST}=east, ${DATA_SVC_WEST}=west)  ####"
echo " ##################################################"
echo
update_property loyalty-login-dataservice-aa.com.akadns.net prod "$DATA_SVC_EAST" "$DATA_SVC_WEST"
# --- Original hardcoded line ---
# akamai gtm --section gtm update-property loyalty-login-dataservice-aa.com.akadns.net prod --target '{"datacenterId": '2',"weight":'$east',"enabled":true}' --target '{"datacenterId": '3',"weight":'$west',"enabled":true}' --verbose

echo " ##################################################"
echo " ####   Loyalty Login MessagingSvc (DC ${MSG_SVC_EAST}=east, ${MSG_SVC_WEST}=west)  ####"
echo " ##################################################"
echo
update_property loyalty-login-messagingsvc-aa.com.akadns.net prod "$MSG_SVC_EAST" "$MSG_SVC_WEST"
# --- Original hardcoded line ---
# akamai gtm --section gtm update-property loyalty-login-messagingsvc-aa.com.akadns.net prod --target '{"datacenterId": '1',"weight":'$east',"enabled":true}' --target '{"datacenterId": '2',"weight":'$west',"enabled":true}' --verbose

echo " ##################################################"
echo " ####   Loyalty PNR Svc (DC ${PNR_SVC_EAST}=east, ${PNR_SVC_WEST}=west)  ####"
echo " ##################################################"
echo
update_property loyalty-pnrsvc-aa.com.akadns.net prod "$PNR_SVC_EAST" "$PNR_SVC_WEST"
# --- Original hardcoded line ---
# akamai gtm --section gtm update-property loyalty-pnrsvc-aa.com.akadns.net prod --target '{"datacenterId": '1',"weight":'$east',"enabled":true}' --target '{"datacenterId": '2',"weight":'$west',"enabled":true}' --verbose

echo " ##################################################"
echo " ####   Loyalty Premerge Service (DC ${PREMERGE_EAST}=east, ${PREMERGE_WEST}=west)  ####"
echo " ##################################################"
echo
update_property loyalty-premerge-service-aa.com.akadns.net prod "$PREMERGE_EAST" "$PREMERGE_WEST"
# --- Original hardcoded line ---
# akamai gtm --section gtm update-property loyalty-premerge-service-aa.com.akadns.net prod --target '{"datacenterId": '2',"weight":'$east',"enabled":true}' --target '{"datacenterId": '3',"weight":'$west',"enabled":true}' --verbose

echo " ##################################################"
echo " ####   Loyalty Profile (DC ${PROFILE_EAST}=east, ${PROFILE_WEST}=west)  ####"
echo " ##################################################"
echo
update_property loyalty-profile-aa.com.akadns.net azure-data-privacy-service-prod "$PROFILE_EAST" "$PROFILE_WEST"
update_property loyalty-profile-aa.com.akadns.net profile-info-bff-prod           "$PROFILE_EAST" "$PROFILE_WEST"
# --- Original hardcoded lines ---
# akamai gtm --section gtm update-property loyalty-profile-aa.com.akadns.net azure-data-privacy-service-prod --target '{"datacenterId": '3132',"weight":'$east',"enabled":true}' --target '{"datacenterId": '3135',"weight":'$west',"enabled":true}' --verbose
# akamai gtm --section gtm update-property loyalty-profile-aa.com.akadns.net profile-info-bff-prod --target '{"datacenterId": '3132',"weight":'$east',"enabled":true}' --target '{"datacenterId": '3135',"weight":'$west',"enabled":true}' --verbose

echo
echo

echo " =================================="
echo " Done. Traffic updated: East=$east%, West=$west%"
echo " =================================="
