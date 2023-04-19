# configuring our network for Tenacity IT
# Create a VPC
  
resource "aws_vpc" "t_city_vpc"{

     cidr_block = "10.0.0.0/16"
     instance_tenancy = "default"
     enable_dns_hostnames = true
     enable_dns_support = true
     tags = {
       "Name" = "test"
     }
    
} 

# creating Pub subnet
resource "aws_subnet" "Prod-Pub-Sub1" {
  vpc_id     = aws_vpc.t_city_vpc.id
  cidr_block = "10.0.1.0/24" 
  availability_zone = "eu-west-2a"

  tags ={
    Name ="Prod-Pub-Sub1"
  }
  }

  resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.t_city_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

    tags ={
    Name ="Prod-pub-Sub2"
  }

  }

  #Pri Subnet creation
  resource "aws_subnet" "Prod-pri-sub1" {
  vpc_id     = aws_vpc.t_city_vpc.id
  cidr_block = "10.0.3.0/24"

tags ={
    Name ="Prod-priv-Sub1"
  }

  }

  resource "aws_subnet" "Prod-pri-sub2" {
  vpc_id     = aws_vpc.t_city_vpc.id
  cidr_block = "10.0.4.0/24"

  }
# Private RT1 creation
 resource "aws_route_table""RT_Private_Side"{

  vpc_id = aws_vpc.t_city_vpc.id

  tags ={
    Name ="RT_Private_Side" 
  }

 }
# Public RT2
 resource "aws_route_table" "RT_Public_Side"{
  vpc_id = aws_vpc.t_city_vpc.id

 tags ={
    Name ="RT_Publice_Side" 
  }
 }

# Subnets & RT Associations
resource "aws_route_table_association" "public-route-association"{
  subnet_id = aws_subnet.Prod-Pub-Sub1.id
     route_table_id = aws_route_table.RT_Public_Side.id
 
 }
  resource "aws_route_table_association""public2-route-association"{
  subnet_id = aws_subnet.Prod-pri-sub2.id
 route_table_id = aws_route_table.RT_Public_Side.id
 
 }

resource "aws_route_table_association""pri-route-association"{
  subnet_id = aws_subnet.Prod-pri-sub1.id
 route_table_id = aws_route_table.RT_Private_Side.id
 
 }
 
resource "aws_route_table_association""pri2-route-association"{ 
  subnet_id = aws_subnet.Prod-pri-sub2.id
   route_table_id =aws_route_table.RT_Private_Side.id
 
 }
 ####Allocate  elastic IP address
resource "aws_eip" "eip_for_nat_gateway" {
  vpc  = true
}

##creating the NAT-Gateway

resource "aws_nat_gateway" "Prod-Nat-gateway" {
    allocation_id = aws_eip.eip_for_nat_gateway.id 
    subnet_id = aws_subnet.Prod-pri-sub1.id
}



#####Associating  NAT gateway with private route table

resource "aws_route" "Prod-Nat-association" {
    gateway_id             = aws_nat_gateway.Prod-Nat-gateway.id
    route_table_id         = aws_route_table.RT_Private_Side.id 
    destination_cidr_block = "0.0.0.0/0"
  

}
 #internet .GW creation
  resource "aws_internet_gateway" "t_city_IGW" {
  vpc_id = aws_vpc.t_city_vpc.id
  
  tags = {
    Name = "test"
  }
  }

   #associating your IGW TO PUBLIC SIDE & DO THE ROUTE

  resource "aws_route" "Pro_Int_GWA" {
  gateway_id     = aws_internet_gateway.t_city_IGW.id
  route_table_id = aws_route_table.RT_Public_Side.id
  destination_cidr_block = "0.0.0.0/0"

 }





    




     
   















