# Create a list of keys
get_key <- function(framesize){
  # Set Quandl available keys
  key <- c("kxgRDGkKCSyyTRRNduxQ","6aTL3KgB6NoRZjDQWAR_","1yNXyvZrtMs6ZdoJGqnq","pZ1hhKssK7Aw7YXWrgHz")
  # assign keys as it is if total chunk size is <=4
  if(framesize <= 4){
    api_keys <- foreach(itr = 1:4, .combine = rbind) %do% {
      key[itr]
    }
  }
  else{# assign keys using round robin if total chunk size > 4
    api_keys <- rep(key,length.out = framesize)
  }
  return(api_keys)
}