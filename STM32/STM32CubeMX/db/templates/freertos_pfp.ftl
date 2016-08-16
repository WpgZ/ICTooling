[#ftl]
[#compress]
[#assign nbThreads = 0]
[#assign generateFunction = "1"]
[#assign option = "Default"]
[#list SWIPdatas as SWIP]
  [#if SWIP.variables??]
	[#list SWIP.variables as variable]
	
	  [#if variable.name == "Threads"]
	    [#assign s = variable.valueList]
	    [#assign index = 0]
        [#list s as i]
          [#if index == 3]
            [#assign threadFunction = i]
          [/#if]
          [#if index == 4]
            [#assign generateFunction = i]
          [/#if]
          [#if index == 5]
            [#assign option = i]
          [/#if]
          [#assign index = index + 1]
        [/#list]
        [#if generateFunction == "1"]
         [#if option == "As external"]
         extern void ${threadFunction}(void const * argument);
         [#else]
         void ${threadFunction}(void const * argument);
         [/#if]
        [/#if]
      [/#if]
      
 	  [#if variable.name == "Timers"]
	    [#assign s = variable.valueList]
	    [#assign index = 0]
        [#list s as i]
          [#if index == 1]
            [#assign timerCallback = i]
          [/#if]
          [#if index == 3]
            [#assign generateCallback = i]
          [/#if]
          [#if index == 4]
            [#assign option = i]
          [/#if]
          [#assign index = index + 1]
        [/#list]
        [#if generateCallback == "1"]
         [#if option == "As external"]
         extern void ${timerCallback}(void const * argument);
         [#else]
         void ${timerCallback}(void const * argument);
         [/#if]
        [/#if]
      [/#if]     
      
	[/#list]
  [/#if]
[/#list]
[/#compress]