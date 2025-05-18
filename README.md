# STARKNET-CAIRO Fırst Contract 

First contract deployment in starknet-goerli test net

- Created make file to automate the deployment 
- Created  
  - Added new python script for converting strings to felt252 vs.
  - Added bash file for generating makefile template.
    usage :
    ```
    chmod +x generate_makef.bash
    ./generate_makef.bash
    ```
- Contract needs string value for constructor and setter function however it needs to be converted into felt252 hexadecimal value, getter function will return felt252 hexadecimal so our python converter can convert them as shown in makefile.
  value of string. 
- Converter can be used seperately if needed.


- Please use help command to see the other commands and effects.
```
make help 
```


```
git clone https://github.com/ASaidOguz/Starknet-Cairo
```