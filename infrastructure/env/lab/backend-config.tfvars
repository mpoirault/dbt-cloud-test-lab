# single env for now, its a lab. when productionalizing, dev/preprod/prod each
# get their own folder here with a backend-config and a vars file, and state is
# split per terraform workspace (thats how pfg does it).
# the prefix still says terraform/state from before the directory rename,
# changing it would mean a state migration for cosmetics. not worth it.
bucket = "dbt-cloud-architect-lab-tfstate"
prefix = "terraform/state"
