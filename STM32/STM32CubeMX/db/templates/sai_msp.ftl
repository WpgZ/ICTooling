[#ftl]

[#compress]
[#-- Add global dma Handler --]
[#list IPdatas as IP]  
[#list IP.configModelList as instanceData]
    [#if instanceData.dmaHandel??]
        [#list instanceData.dmaHandel as dHandle]
            extern ${dHandle};#n
        [/#list]
    [/#if]
[/#list]
[/#list]

[/#compress]

[#list IPdatas as IP]  
[#assign ipvar = IP]

[#assign useGpio = false]
[#assign useDma = false]
[#assign useNvic = false]
[#-- extract hal mode list used by all instances of the ip --]
[#assign halModeList= ""]
[#list ipvar.instances.entrySet() as entry]
        [#if halModeList?contains(entry.value)]
        [#else]
            [#assign halModeList = halModeList + " " +entry.value]
        [/#if]
[/#list]
[#-- End extract hal mode list used by all instances of the ip --]

[#-- Define includes --]
[#list IP.configModelList as instanceData]
[#if instanceData.initServices??]
    [#if instanceData.initServices.gpioA?? || instanceData.initServices.gpioB??]
        [#assign useGpio = true]
    [/#if]
    [#if instanceData.initServices.dmaA??||instanceData.initServices.dmaB??]
        [#assign useDma = true]
    [/#if]
    [#if instanceData.initServices.nvicA??||instanceData.initServices.nvicB??]
        [#assign useNvic = true]
    [/#if]
  [/#if]
[/#list]

[#-- End Define includes --]

[#-- Function getInitServiceMode --]
[#function getInitServiceMode(ipname1)]
    [#-- assign initServicesList = {"test0":"test1"}--]
    [#assign initServicesList = ""]
    [#list ipvar.configModelList as instanceData]
        [#if instanceData.halInstanceName==ipname1]
            [#assign initServicesList = {"test0":"test1"}]
            [#if instanceData.initServices??]
                [#return instanceData.initServices]
            [/#if]
        [/#if]
    [/#list]
   [#return initServicesList]
[/#function]
[#-- End Function getInitServiceMode --]

[#-- Function getDeInitServiceMode --]
[#function getDeInitServiceMode(ipname2)]
    [#-- assign initServicesList = {"test0":"test1"}--]
    [#assign deInitServicesList = ""]
    [#list ipvar.configModelList as instanceData]
        [#if instanceData.halInstanceName==ipname2]
            [#assign deInitServicesList = {"test0":"test1"}]
            [#if instanceData.deInitServices??]
                [#return instanceData.deInitServices]
            [/#if]
        [/#if]
    [/#list]
   [#return deInitServicesList]
[/#function]
[#-- End Function getDeInitServiceMode --]

[#-- macro generateConfigCode --]
[#macro generateConfigCode ipName type serviceName instHandler tabN]
[#if type=="Init"]
 [#assign service = getInitServiceMode(ipName)]
[#else]
 [#assign service = getDeInitServiceMode(ipName)]
[/#if]
[#if serviceName=="gpioA"]
    [#if service.gpioA??][#assign gpioServiceA = service.gpioA][#else][#assign gpioServiceA = ""][/#if]
[/#if]
[#if serviceName=="gpioB"]
    [#if service.gpioB??][#assign gpioServiceB = service.gpioB][#else][#assign gpioServiceB = ""][/#if]
[/#if]

[#if serviceName=="dmaA" && service.dmaA??]
[#assign dmaServiceA = service.dmaA]
[/#if]
[#if serviceName=="dmaB" && service.dmaB??]
[#assign dmaServiceB = service.dmaB]
[/#if]   
[#if serviceName=="gpioA" && service.gpioA?? && (service.gpioA!="")]
 [#assign instanceIndex =""]
    [@common.generateConfigModelCode configModel=gpioServiceA inst=ipName nTab=tabN index=""/]
[/#if]
[#if serviceName=="gpioB" && service.gpioB?? && (service.gpioB!="")]
 [#assign instanceIndex =""]
    [@common.generateConfigModelCode configModel=gpioServiceB inst=ipName nTab=tabN index=""/]
[/#if]
[#if serviceName=="dmaA" && dmaServiceA??]
 [#assign instanceIndex =""]
    [#list dmaServiceA as dmaconfig] 
     [@common.generateConfigModelCode configModel=dmaconfig inst=ipName  nTab=tabN index=""/]
        [#assign dmaCurrentRequest = dmaconfig.dmaRequestName?lower_case]
        [#assign prefixList = dmaCurrentRequest?split("_")]
        [#list prefixList as p][#assign prefix= p][/#list]
      [#if dmaconfig.dmaHandel?size > 1] [#-- if more than one dma handler--]
        [#assign channel="channel"]
        [#if (FamilyName=="STM32F2" || FamilyName=="STM32F4" || FamilyName=="STM32F7")]
          [#assign channel="stream"]
        [/#if]
#t#t/* Several peripheral DMA handle pointers point to the same DMA handle.
#t#t   Be aware that there is only one ${channel} to perform all the requested DMAs. */
[/#if]   [#-- if more than one dma handler--] 
                            [#list dmaconfig.dmaHandel as dmaH]
#t#t__HAL_LINKDMA(${instHandler},${dmaH},hdma_${dmaconfig.dmaRequestName?lower_case});
#n
                            [/#list]
    [/#list] [#-- list dmaService as dmaconfig --]
#n
[/#if]
[#if serviceName=="dmaB" && dmaServiceB??]
 [#assign instanceIndex =""]
    [#list dmaServiceB as dmaconfig] 
     [@common.generateConfigModelCode configModel=dmaconfig inst=ipName  nTab=tabN index=""/]
        [#assign dmaCurrentRequest = dmaconfig.dmaRequestName?lower_case]
        [#assign prefixList = dmaCurrentRequest?split("_")]
        [#list prefixList as p][#assign prefix= p][/#list]
        [#if dmaconfig.dmaHandel?size > 1] [#-- if more than one dma handler--]
        [#assign channel="channel"]
        [#if (FamilyName=="STM32F2" || FamilyName=="STM32F4" || FamilyName=="STM32F7")]
          [#assign channel="stream"]
        [/#if]
#t#t/* Several peripheral DMA handle pointers point to the same DMA handle.
#t#t   Be aware that there is only one ${channel} to perform all the requested DMAs. */
  [/#if]   [#-- if more than one dma handler--] 
                            [#list dmaconfig.dmaHandel as dmaH]
#t#t__HAL_LINKDMA(${instHandler},${dmaH},hdma_${dmaconfig.dmaRequestName?lower_case});
                            [/#list]
                      
    [/#list] [#-- list dmaService as dmaconfig --]
[/#if]
[/#macro]
[#-- End macro generateConfigCode --]
[#-- function: getHalMode(ipInstanceName) --]
[#function getHalMode ipname]
    [#list ipvar.instances.entrySet() as entry]
        [#if entry.key==ipname]
            ${entry.value}
        [/#if]
    [#return entry.value]
    [/#list]
[/#function]
[#-- End function: getHalMode(ipInstanceName) --]

[#-- function: getDmaHandler(currentipname) --]
[#function getDmaHandler currentipname]
    [#assign result=""]
    [#list ipvar.configModelList as instanceData]
        [#if instanceData.instanceName==currentipname]
            [#if instanceData.dmaHandel??] [#assign result=instanceData.dmaHandel][/#if]
        [/#if]
    [/#list] 
    [#return result]   
[/#function]
[#-- End function: getDmaHandler(currentipname) --]

[#-- macro generate service code for MspInit/MspDeInit Start--]
[#macro generateServiceCode ipName serviceType modeName instHandler tabN]
    [#if serviceType=="Init"]
        [#assign initService = getInitServiceMode(ipName)]
    [#else]
        [#assign initService = getDeInitServiceMode(ipName)]
    [/#if]
        [#assign gpioExist = false]
        [#assign dmaExist = false]
        [#assign nvicExist = false]
[#assign gpioExistA = false]
        [#assign dmaExistA = false]
        [#assign nvicExistA = false]
[#assign gpioExistB = false]
        [#assign dmaExistB = false]
        [#assign nvicExistB = false]
        [#if initService?? && initService.entrySet??]
        [#list initService.entrySet() as entry]
            [#if entry.key=="dma"]
            [#assign dmaExist = true]
            [/#if]
            [#if entry.key=="dmaA"] 
            [#assign dmaExistA = true]
            [/#if]
            [#if entry.key=="dmaB"]
            [#assign dmaExistB = true]
            [/#if]
            [#if entry.key=="nvic"]
            [#assign nvicExist = true]
            [/#if]
[#if entry.key=="nvicA"]
            [#assign nvicExistA = true]
            [/#if]
[#if entry.key=="nvicB"]
            [#assign nvicExistB = true]
            [/#if]
            [#if entry.key=="gpioA"]
            [#assign gpioExistA = true]
            [/#if]
            [#if entry.key=="gpioB"]
            [#assign gpioExistB = true]
            [/#if]            
        [/#list]
        [/#if] 
[#if gpioExistA]   
 #t#tif(hsai->Instance==${ipName}_Block_A)  
#t#t{    
    [#if serviceType=="Init"]  #t#t/* Peripheral clock enable */
#t#tif (${ipName}_client == 0)
#t#t{
           [#if initService.clock??]
            [#list initService.clock?split(';') as clock]
               #t#t#t ${clock}(); 
            [/#list]
            [#else]
         #t#t#t__HAL_RCC_${ipName}_CLK_ENABLE();
           [/#if]
        [#if nvicExist]
            [#if initService.nvic??&&initService.nvic?size>0]
                [#assign irqNum = 0]
                [#list initService.nvic as initVector]
                  [#if initVector.codeInMspInit]
                    [#assign irqNum = irqNum+1]
                    [#if irqNum==1]#n#t#t/* Peripheral interrupt init*/[/#if]
                    #t#tHAL_NVIC_SetPriority(${initVector.vector}, ${initVector.preemptionPriority}, ${initVector.subPriority});
                    #t#tHAL_NVIC_EnableIRQ(${initVector.vector});
                  [/#if]
                [/#list]
            [/#if]
        [/#if]
#t#t}
#t#t${ipName}_client ++;
    [#else]    
#t#t${ipName}_client --;
#t#tif (${ipName}_client == 0)
#t#t#t{       
        #t#t#t/* Peripheral clock disable */ #n #t#t#t__HAL_RCC_${ipName}_CLK_DISABLE();
[#if initService.nvic??]
                [#list initService.nvic as initVector]                   
                    #t#t#tHAL_NVIC_DisableIRQ(${initVector.vector});
                [/#list]
            [/#if]
#t#t#t}
    [/#if] 

  
#t#t[@generateConfigCode ipName=ipName type=serviceType serviceName="gpioA" instHandler=instHandler tabN=tabN/]
[#if dmaExistA &&  serviceType=="Init"]#n#t#t/* Peripheral DMA init*/
#t#t[@generateConfigCode ipName=ipName type=serviceType serviceName="dmaA" instHandler=instHandler tabN=tabN/]
[#else]
    [#if dmaExistA]
        [#assign service = getInitServiceMode(ipName)]
[#if service.dmaA??]
        [#assign dmaserviceA =service.dmaA]
        [#list dmaserviceA as dmaconfig]
            [#assign dmaCurrentRequest = dmaconfig.dmaRequestName?lower_case]
            [#assign prefixList = dmaCurrentRequest?split("_")]
            [#list prefixList as p][#assign prefix= p][/#list]
            [#assign ipdmahandler1 = "hdma" + prefix]
             [#-- [#if getDmaHandler(ipName)!=""][#assign ipdmahandler = getDmaHandler(ipName)][#else][#assign ipdmahandler = ipdmahandler1][/#if]--]
               [#if dmaconfig.dmaHandel??][#assign ipdmahandler = dmaconfig.dmaHandel][#else][#assign ipdmahandler = ipdmahandler1][/#if]
[#if dmaconfig.dmaHandel?size > 1] [#-- if more than one dma handler--]
                        [/#if]   [#-- if more than one dma handler--]

                            [#list dmaconfig.dmaHandel as dmaH]
[#compress]                              #t#tHAL_DMA_DeInit(${instHandler}->${dmaH});[/#compress]
                            [/#list]
                   
        [/#list] [#-- list dmaService as dmaconfig --]
    [/#if][#-- if service.dmaA --]
    [/#if]
 [/#if]
#t#t}	
[/#if]

[#if gpioExistB]
#t#tif(hsai->Instance==${ipName}_Block_B)
#t#t{
    [#if serviceType=="Init"]  #t#t#t/* Peripheral clock enable */
#t#t#tif (${ipName}_client == 0)
#t#t#t{
           [#if initService.clock??]
            [#list initService.clock?split(';') as clock]
               #t#t#t ${clock}(); 
            [/#list]
            [#else]
         #t#t#t__HAL_RCC_${ipName}_CLK_ENABLE();
           [/#if]
        [#if nvicExist]
            [#if initService.nvic??&&initService.nvic?size>0]
                [#assign irqNum = 0]
                [#list initService.nvic as initVector]
                  [#if initVector.codeInMspInit]
                    [#assign irqNum = irqNum+1]
                    [#if irqNum==1]#n#t#t#t/* Peripheral interrupt init*/[/#if]
                    #t#t#tHAL_NVIC_SetPriority(${initVector.vector}, ${initVector.preemptionPriority}, ${initVector.subPriority});
                    #t#t#tHAL_NVIC_EnableIRQ(${initVector.vector});
                  [/#if]
                [/#list]
            [/#if]
        [/#if]
#t#t#t}
#t#t${ipName}_client ++;
    [#else]         
#t#t${ipName}_client --;
#t#t#tif (${ipName}_client == 0)
#t#t#t{  
        #t#t#t/* Peripheral clock disable */#n#t#t#t__HAL_RCC_${ipName}_CLK_DISABLE(); 
[#if initService.nvic??]
                [#list initService.nvic as initVector]                   
                    #t#t#tHAL_NVIC_DisableIRQ(${initVector.vector});
                [/#list]
            [/#if]
#t#t#t}
    [/#if] 


#t#t[@generateConfigCode ipName=ipName type=serviceType serviceName="gpioB" instHandler=instHandler tabN=tabN/]	
[#if dmaExistB && serviceType=="Init"]#n#t#t/* Peripheral DMA init*/
#t#t[@generateConfigCode ipName=ipName type=serviceType serviceName="dmaB" instHandler=instHandler tabN=tabN/]
[#else]
[#if dmaExistB]
[#assign service = getInitServiceMode(ipName)]
[#if service.dmaB??]
    [#assign dmaserviceB =service.dmaB]
    [#list dmaserviceB as dmaconfig]
        [#assign dmaCurrentRequest = dmaconfig.dmaRequestName?lower_case]
        [#assign prefixList = dmaCurrentRequest?split("_")]
        [#list prefixList as p][#assign prefix= p][/#list]
        [#assign ipdmahandler1 = "hdma" + prefix]
         [#-- [#if getDmaHandler(ipName)!=""][#assign ipdmahandler = getDmaHandler(ipName)][#else][#assign ipdmahandler = ipdmahandler1][/#if]--]
           [#if dmaconfig.dmaHandel??][#assign ipdmahandler = dmaconfig.dmaHandel][#else][#assign ipdmahandler = ipdmahandler1][/#if]
                            [#list dmaconfig.dmaHandel as dmaH]
[#compress]                              #t#tHAL_DMA_DeInit(${instHandler}->${dmaH});[/#compress]
                            [/#list]
    [/#list] [#-- list dmaService as dmaconfig --]
[/#if][#--if service.dmaB??--]
[/#if]
[/#if]
#t#t}
[/#if]


[/#macro]
[#-- End macro add service code --]


[#assign initServicesList = {"test0":"test1"}]

[#-- Section2: Msp Init --]
[#if ipvar.initCallBacks??]
[#compress]
[#list ipvar.initCallBacks.entrySet() as entry]
[#assign instanceList = entry.value]
[#list instanceList as saiInst]
static uint32_t ${saiInst}_client =0;
[/#list]
[#assign mode=entry.key?replace("_MspInit","")?replace("_BspInit","")?replace("HAL_","")]

[#assign ipHandler = "h" + mode?lower_case]


[#-- #nvoid HAL_${mode}_MspInit(${mode}_HandleTypeDef* h${mode?lower_case}){--] 
#nvoid ${entry.key}(${mode}_HandleTypeDef* h${mode?lower_case})
{
#n
[#-- Search for static variables Start--]
[#list instanceList as inst]

     [#assign services = getInitServiceMode(inst)]
[#if services.dma??]
     [#assign dmaService=services.dma]   
    [#if dmaService?? && dmaService?size!=0]
    [#list dmaService as dmaRequest]
        [#list dmaRequest.methods as method]	
		[#if method.status=="OK" && method.arguments??]
                    [#list method.arguments as fargument]
                        [#if fargument.genericType == "struct" && fargument.context??]
                            [#if fargument.context=="global"]
[#--#tstatic ${fargument.typeName} ${fargument.name}_${dmaRequest.dmaRequestName?lower_case};--]
                            [/#if]
                        [/#if]
                    [/#list]
                [/#if]
         [/#list]

     [/#list] [#-- list dmaService as dmaRequest --]
     [/#if]   [#-- if dmaService?? && dmaService.size!=0 --]
[/#if]
[/#list]

[#assign words = instanceList]
[#-- declare Variable GPIO_InitTypeDef once --]
       [#assign v = ""]
[#list words as inst] [#-- loop on ip instances datas --] 
 [#assign services = getInitServiceMode(inst)]
 [#if services.gpioA??][#assign service=services.gpioA]
        [#list service.variables as variable] [#-- variables declaration --]
            [#if v?contains(variable.name)]
            [#-- no matches--]
            [#else]
#t${variable.value} ${variable.name};
                [#assign v = v + " "+ variable.name/]	
            [/#if]	
        [/#list]  
[#else][#if services.gpioB??][#assign service=services.gpioB]
        [#list service.variables as variable] [#-- variables declaration --]
            [#if v?contains(variable.name)]
            [#-- no matches--]
            [#else]
#t${variable.value} ${variable.name};
                [#assign v = v + " "+ variable.name/]	
            [/#if]	
        [/#list]  
[/#if]
[/#if]
[#if services.gpioA??][#assign service=services.gpioA]
        [#list service.variables as variable] [#-- variables declaration --]
            [#if v?contains(variable.name)]
            [#-- no matches--]
            [#else]
#t${variable.value} ${variable.name};
                [#assign v = v + " "+ variable.name/]	
            [/#if]	
        [/#list]  
[#else][#if services.gpioB??][#assign service=services.gpioB]
        [#list service.variables as variable] [#-- variables declaration --]
            [#if v?contains(variable.name)]
            [#-- no matches--]
            [#else]
#t${variable.value} ${variable.name};
                [#assign v = v + " "+ variable.name/]	
            [/#if]	
        [/#list]  
[/#if]
[/#if]
[/#list]
[#-- --]
[#list words as sai]
/* ${sai} */
    [@generateServiceCode ipName=sai serviceType="Init" modeName=mode instHandler=ipHandler tabN=2/] 
[/#list] 
}
[/#list]
[/#compress]
[/#if]
[#-- Section2:End --]


[#if ipvar.deInitCallBacks??]
[#compress]
[#list ipvar.deInitCallBacks.entrySet() as entry]
[#assign instanceList = entry.value]
[#assign mode=entry.key?replace("_MspDeInit","")?replace("_BspDeInit","")?replace("HAL_","")]
[#assign ipHandler = "h" + mode?lower_case]

#nvoid ${entry.key}(${mode}_HandleTypeDef* h${mode?lower_case})
[#assign words = instanceList]
{
#n

[#list words as sai]
/* ${sai} */
    [@generateServiceCode ipName=sai serviceType="DeInit" modeName=mode instHandler=ipHandler tabN=2/] 
[/#list]
}
[/#list]
[/#compress]
[/#if]
[#-- Section3: End --]
[/#list]