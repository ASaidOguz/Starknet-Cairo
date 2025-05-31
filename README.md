# STARKNET-CAIRO Fırst Contract 
[Scarb](https://docs.swmansion.com/scarb/docs.html) and [Cairo-coverage](https://github.com/software-mansion/cairo-coverage) you can download and use them for the projects. 
First contract deployment in starknet-sepolia test net

- Created make file to automate the deployment 
- Created  
  - Added new python script for converting strings to felt252 vs.
  - Added bash file for generating makefile template.The white space problems kinda hussle so use bash script to create template.
    usage :
    ```
    chmod +x generate_makef.bash
    ./gen-makefile.bash
    ```
    Script can be used for mostly all project where it searches for contract code to create declare and deploy makefile scripts.Though argument sections are set user set values so you need to set them yourself.
- Contract needs string value for constructor and setter function however it needs to be converted into felt252 hexadecimal value, getter function will return felt252 hexadecimal so our python converter can convert them as shown in makefile.
  value of string. 
- Converter can be used seperately if needed.
- Simple test added by snforge(Starknet Foundry) +++

- Please use help command to see the other commands and effects.
```
make help 
```


```
git clone https://github.com/ASaidOguz/Starknet-Cairo
```

