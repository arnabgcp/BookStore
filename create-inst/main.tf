resource "random_integer" "ri" {

 min=10
 max=500 
}

module "newmod"{

source = "../module/standalone"

region="europe-west1"
instance="sql-inst-${random_integer.ri.id}"
project="halogen-premise-338015"


}