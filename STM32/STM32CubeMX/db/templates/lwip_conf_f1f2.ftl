[#ftl]

/**
  ******************************************************************************
  * File Name          : ${name}
  * Description        : This file overrides LwIP stack default configuration
  *                      done in opt.h file.
  ******************************************************************************
  *
  * COPYRIGHT(c) ${year} STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *   1. Redistributions of source code must retain the above copyright notice,
  *      this list of conditions and the following disclaimer.
  *   2. Redistributions in binary form must reproduce the above copyright notice,
  *      this list of conditions and the following disclaimer in the documentation
  *      and/or other materials provided with the distribution.
  *   3. Neither the name of STMicroelectronics nor the names of its contributors
  *      may be used to endorse or promote products derived from this software
  *      without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  *
  ******************************************************************************
  */
 
[#assign s = name]
[#assign s_new = s?replace(".","__")]
[#assign inclusion_protection = s_new?upper_case]
/* Define to prevent recursive inclusion --------------------------------------*/
#ifndef __${inclusion_protection}__
#define __${inclusion_protection}__

#include "${FamilyName?lower_case}xx_hal.h"

[#-- SWIPdatas is a list of SWIPconfigModel --]
[#list SWIPdatas as SWIP]

[#if SWIP.defines??]
    [#list SWIP.defines as definition]
       [#if definition.name == "LwIP Version"]
/*-----------------------------------------------------------------------------*/
/* Current version of LwIP supported by CubeMx: ${definition.value} -*/
/*-----------------------------------------------------------------------------*/

       [/#if]
    [/#list]
[/#if]

/* Within 'USER CODE' section, code will be kept by default at each generation */
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

#ifdef __cplusplus
 extern "C" {
#endif

[#if includes??]
/* Includes -------------------------------------------------------------------*/
[#list includes as include]
#include "${include}"
[/#list]
[/#if] [#-- includes?? --]


[#-- Global variables --]
[#if SWIP.variables??]
	[#list SWIP.variables as variable]
extern ${variable.value} ${variable.name};
	[/#list]
[/#if] [#-- SWIP.variables?? --]
[#-- Global variables --]

[#-- Parameters always visible and dependent from RTOS (NO_SYS) >> avoid using default value --]
[#assign rtosNoMaskList = ["NO_SYS", "LWIP_NETCONN", "LWIP_SOCKET", "WITH_RTOS", "LWIP_NETIF_LOOPBACK_MULTITHREADING"]]
[#-- Parameters Visible only if RTOS AND with default values different for the same parameter >> avoid using default value  --]
[#assign rtosMaskList = ["TCPIP_THREAD_STACKSIZE", "TCPIP_THREAD_PRIO", "SLIPIF_THREAD_STACKSIZE", "SLIPIF_THREAD_PRIO", "DEFAULT_THREAD_STACKSIZE", "DEFAULT_THREAD_PRIO",
                          "LWIP_COMPAT_SOCKETS", "LWIP_SOCKET_SET_ERRNO", "LWIP_POSIX_SOCKETS_IO_NAMES"]]
[#-- STATS Parameters are disabled in CubeMx (enable in opt.h) >> avoid using default value --]
[#assign statList = ["LINK_STATS", "ETHARP_STATS", "IP_STATS", "IPFRAG_STATS", "ICMP_STATS", "IGMP_STATS", "UDP_STATS", "TCP_STATS", "MEM_STATS", "MEMP_STATS", "SYS_STATS", 
                             "IP6_STATS", "ICMP6_STATS", "IP6_FRAG_STATS", "MLD6_STATS"]]
[#-- Special parameters LWIP_DNS_SECURE cannot consider default value (logical OR) >> avoid using default value --]
[#-- Special parameters LWIP_DHCP is enabled in CubeMx (disabled in opt.h) >> avoid using default value --]
[#-- Special parameters CHECKSUM_BY_HARDWARE should be excluded since it is generated in STM32CubeMX Specific Parameters section --]
[#assign specialList = ["LWIP_DNS_SECURE", "LWIP_DHCP", "CHECKSUM_BY_HARDWARE"]]

[#-- Checksum parameters enabled (in opt.h) and disabled in CubeMx --]
[#assign checksumList = ["CHECKSUM_GEN_IP", "CHECKSUM_GEN_UDP", "CHECKSUM_GEN_TCP", "CHECKSUM_GEN_ICMP", "CHECKSUM_GEN_ICMP6", "CHECKSUM_CHECK_IP", "CHECKSUM_CHECK_UDP", "CHECKSUM_CHECK_TCP", "CHECKSUM_CHECK_ICMP", "CHECKSUM_CHECK_ICMP6"]]

[#-- CubeMx internal parameters --]
[#assign nonStdList = ["NETMASK_ADDRESS", "GATEWAY_ADDRESS", "IP_ADDRESS", "heth", "gnetif", "ipaddr", "netmask", "gw"]]


[#-- Function to test if a parameter belong to a list of parameters --]
[#function isParamInList paramName paramList]
    [#assign used=false]
    [#list paramList as param]
        [#if param==paramName]
            [#assign used=true]
            [#return true]
        [/#if]
    [/#list]
    [#return used]
[/#function]

[#assign instName = SWIP.ipName]
[#assign fileName = SWIP.fileName]
[#assign version = SWIP.version]
	
[#if SWIP.defines??]
	[#list SWIP.defines as definition]
	    [#-- Following settings are necessary for parameters linked to other one(s) and listed hereafter --]
		[#if definition.name == "NO_SYS"] 
			[#if definition.value == "0"] 
			    [#assign lwip_rtos = 1]
			[#else]	
			    [#assign lwip_rtos = 0] 
			[/#if]
		[/#if]	 
		[#if definition.name == "LWIP_STATS"] [#assign lwip_stats = definition.value] [/#if]
		[#if definition.name == "LWIP_SO_RCVBUF"] [#assign lwip_so_rcvbuf = definition.value] [/#if]
		[#if definition.name == "MEMP_NUM_TCPIP_MSG_API"] [#assign memp_num_tcpip_msg_api = definition.value] [/#if]
        [#if definition.name == "MEMP_NUM_PPP_PCB"] [#assign memp_num_ppp_pcb = definition.value] [/#if]
        [#if definition.name == "ETH_PAD_SIZE"] [#assign eth_pad_size = definition.value] [/#if]
        [#if definition.name == "TCP_WND"] [#assign tcp_wnd = definition.value] [/#if]
        [#if definition.name == "TCP_SND_BUF"] [#assign tcp_snd_buf = definition.value] [/#if]
        [#if definition.name == "TCP_MSS"] [#assign tcp_mss = definition.value] [/#if]        
		[#if definition.name == "IP_DEFAULT_TTL"] [#assign ip_default_ttl = definition.value] [/#if]
        [#if definition.name == "LWIP_TCP"] [#assign lwip_tcp = definition.value] [/#if]
        [#if definition.name == "LWIP_NETIF_LOOPBACK"]  [#assign lwip_netif_loopback = definition.value] [/#if]
        [#if definition.name == "PPP_SUPPORT"] [#assign ppp_support = definition.value] [/#if]
        [#if definition.name == "PPPOL2TP_SUPPORT"]  [#assign pppol2tp_support = definition.value] [/#if]
        [#if definition.name == "CHAP_SUPPORT"] [#assign chap_support = definition.value] [/#if]
        [#if definition.name == "EAP_SUPPORT"] [#assign eap_support = definition.value] [/#if]       
        [#if definition.name == "PPPOL2TP_AUTH_SUPPORT"] [#assign pppol2tp_auth_support = definition.value] [/#if]
        [#if definition.name == "LWIP_HAVE_SLIPIF"] [#assign lwip_have_slipif = definition.value] [/#if]       
        [#if definition.name == "LWIP_IPV6"] [#assign lwip_ipv6 = definition.value] [/#if]
        [#if definition.name == "LWIP_ICMP"] [#assign lwip_icmp = definition.value] [/#if]
        [#if definition.name == "LWIP_ICMP6"][#assign lwip_icmp6 = definition.value] [/#if]
        [#if definition.name == "LWIP_ARP"] [#assign lwip_arp = definition.value] [/#if]
        [#if definition.name == "IP_REASSEMBLY"] [#assign ip_reassembly = definition.value] [/#if]
        [#if definition.name == "IP_FRAG"] [#assign ip_frag = definition.value] [/#if]
        [#if definition.name == "LWIP_IGMP"] [#assign lwip_igmp = definition.value] [/#if]
        [#if definition.name == "LWIP_UDP"] [#assign lwip_udp = definition.value] [/#if]
        [#if definition.name == "MEMP_MEM_MALLOC"] [#assign memp_mem_malloc = definition.value] [/#if]
        [#if definition.name == "MEM_LIBC_MALLOC"] [#assign mem_libc_malloc = definition.value] [/#if]
        [#if definition.name == "MEM_USE_POOLS"] [#assign mem_use_pools = definition.value] [/#if]
        [#if definition.name == "LWIP_IPV6_FRAG"] [#assign lwip_ipv6_frag = definition.value] [/#if]
        [#if definition.name == "LWIP_IPV6_REASS"] [#assign lwip_ipv6_reass = definition.value] [/#if]
        [#if definition.name == "LWIP_IPV6_MLD"] [#assign lwip_ipv6_mld = definition.value] [/#if]
        [#if definition.name == "CHECKSUM_BY_HARDWARE"] [#assign checksum_by_hw = definition.value] [/#if]
        [#if definition.name == "LWIP_IPV4"] [#assign lwip_ipv4 = definition.value] [/#if]      
	[/#list]

[#compress]

/* STM32CubeMX Specific Parameters (not defined in opt.h) ---------------------*/
/* Parameters set in STM32CubeMX LwIP Configuration GUI -*/
	[#list SWIP.defines as definition]
       [#if definition.name == "WITH_RTOS"]
           [#if lwip_rtos == 1]
/*----- ${definition.name} enabled (Since FREERTOS is set) -----*/
#define ${definition.name}   1
           [#else]
/*----- ${definition.name} disabled (Since FREERTOS is not set) -----*/
#define ${definition.name}   0
           [/#if]
       [/#if]
       [#if definition.name == "CHECKSUM_BY_HARDWARE"]
           [#if checksum_by_hw == "1"]
/*----- ${definition.name} enabled -----*/
#define ${definition.name}   1
           [#else]
/*----- ${definition.name} disabled -----*/
#define ${definition.name}   0
           [/#if]
       [/#if]
	[/#list]
[/#compress]

/*-----------------------------------------------------------------------------*/


[#if lwip_so_rcvbuf == "1"]
/* LWIP_SO_RCVBUF is enabled => this requires INT_MAX definition in limits.h --*/
#include "limits.h"
[/#if]

/* LwIP Stack Parameters (modified compared to initialization value in opt.h) -*/
/* Parameters set in STM32CubeMX LwIP Configuration GUI -*/
[#compress]	
	[#list SWIP.defines as definition]
		[#if (definition.defaultValue != definition.value) && (definition.value != "valueNotSetted") && !isParamInList(definition.name nonStdList) && !isParamInList(definition.name checksumList) && !isParamInList(definition.name rtosNoMaskList) 
		    && !isParamInList(definition.name rtosMaskList) && !isParamInList(definition.name statList) && !isParamInList(definition.name specialList)]
		    [#-- In all cases where value is not the one in opt.h >> generate #define --]  
/*----- Default Value for ${definition.name}: ${definition.defaultValue} ---*/
#define ${definition.name}  ${definition.value}
		[#else]
		    [#-- Case1 where default value equals user value but #define generation is forced since the setting is different than in opt.h--]
		    [#-- Case2 where param1 = param2 by default, user change param2 and modify after param1 to keep default value => generate it in this case --]
			[#if (definition.name=="LWIP_ETHERNET")] [#-- LWIP_ETHERNET is systematically generated since LWIP cannot be enabled wo ETH --]
/*----- Value in opt.h for ${definition.name}: LWIP_ARP || PPPOE_SUPPORT -*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_DHCP") && (definition.value == "1")]
/*----- Value in opt.h for ${definition.name}: 0 -----*/
#define ${definition.name}   ${definition.value}
            [/#if]            
			[#if (definition.name=="NO_SYS") && (definition.value !="0")]
/*----- Value in opt.h for ${definition.name}: 0 -----*/
#define ${definition.name}  ${definition.value}
			[/#if]
			[#if (definition.name=="MEM_ALIGNMENT")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="MEMP_NUM_SYS_TIMEOUT") && (definition.value != "valueNotSetted") && (definition.value == "5")]
/*----- Value in opt.h for ${definition.name}: (LWIP_TCP + IP_REASSEMBLY + LWIP_ARP + (2*LWIP_DHCP) + LWIP_AUTOIP + LWIP_IGMP + LWIP_DNS + PPP_SUPPORT) -*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="MEMP_NUM_PPPOS_INTERFACES") && (definition.value != "valueNotSetted") && (definition.value != memp_num_ppp_pcb)]
/*----- Value in opt.h for ${definition.name}: MEMP_NUM_PPP_PCB -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="MEMP_NUM_API_MSG") || (definition.name=="MEMP_NUM_DNS_API_MSG") || (definition.name=="MEMP_NUM_SOCKET_SETGETSOCKOPT_DATA") || (definition.name=="MEMP_NUM_NETIFAPI_MSG")] 
                [#if (definition.value != memp_num_tcpip_msg_api) && (definition.value != "valueNotSetted")]
/*----- Value in opt.h for ${definition.name}: MEMP_NUM_TCPIP_MSG_API -----*/
#define ${definition.name}  ${definition.value}
                [/#if]
            [/#if]
            [#if (definition.name=="PBUF_LINK_HLEN") && (definition.value == "14") && (definition.value != "valueNotSetted") && (eth_pad_size != "0")]
/*----- Value in opt.h for ${definition.name}: 14+ETH_PAD_SIZE -----*/
#define ${definition.name}  ${definition.value}
            [/#if]            
            [#if (definition.name=="LWIP_NETCONN") && (definition.value != "valueNotSetted") && (definition.value !="1")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_SOCKET") && (definition.value != "valueNotSetted") && (definition.value !="1")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_MULTICAST_TX_OPTIONS") && (definition.value != "valueNotSetted") && (definition.value != lwip_igmp)]
/*----- Value in opt.h for ${definition.name}: LWIP_IGMP ------*/
#define ${definition.name}  ${definition.value}
            [/#if]	
            [#if ((definition.name=="ICMP_TTL")||(definition.name=="RAW_TTL")||(definition.name=="UDP_TTL")||(definition.name=="TCP_TTL")) && (definition.value != ip_default_ttl) && (definition.value != "valueNotSetted")]
/*----- Value in opt.h for ${definition.name}: IP_DEFAULT_TTL -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_DNS_SECURE") && (definition.value != "valueNotSetted")] [#-- Generate always this param --]
/*----- Value in opt.h for ${definition.name}: (LWIP_DNS_SECURE_RAND_XID | LWIP_DNS_SECURE_NO_MULTIPLE_OUTSTANDING | LWIP_DNS_SECURE_RAND_SRC_PORT) -*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="TCP_WND") && (definition.value != "valueNotSetted") && (definition.value == "2144") && (tcp_mss != "536")]
/*----- Value in opt.h for ${definition.name}: 4 * TCP_MSS -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="TCP_QUEUE_OOSEQ") && (definition.value != "valueNotSetted") && (definition.value != lwip_tcp)]
/*----- Value in opt.h for ${definition.name}: LWIP_TCP -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="TCP_SND_BUF") && (definition.value != "valueNotSetted") && (definition.value == "1072") && (tcp_mss != "536")]
/*----- Value in opt.h for ${definition.name}: 2 * TCP_MSS -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="TCP_SND_QUEUELEN") && (definition.value != "valueNotSetted") && (definition.value == "9")]
/*----- Value in opt.h for ${definition.name}: (4*TCP_SND_BUF + (TCP_MSS - 1))/TCP_MSS -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="TCP_SNDLOWAT") && (definition.value != "valueNotSetted") && (definition.value == "1071")]
/*----- Value in opt.h for ${definition.name}: LWIP_MIN(LWIP_MAX(((TCP_SND_BUF)/2), (2 * TCP_MSS) + 1), (TCP_SND_BUF) - 1) -*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="TCP_SNDQUEUELOWAT") && (definition.value != "valueNotSetted") && (definition.value == "5")]
/*----- Value in opt.h for ${definition.name}: LWIP_MAX(TCP_SND_QUEUELEN)/2, 5) -*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="TCP_WND_UPDATE_THRESHOLD") && (definition.value != "valueNotSetted") && (definition.value == "536")]
/*----- Value in opt.h for ${definition.name}: LWIP_MIN(TCP_WND/4, TCP_MSS*4) -----*/
#define ${definition.name}  ${definition.value}
            [/#if]            
            [#if (definition.name=="LWIP_NETIF_LOOPBACK_MULTITHREADING") && (definition.value != "valueNotSetted") && (((definition.value == "0") && (lwip_rtos == 1)) || ((definition.value == "1") && (lwip_rtos == 0)))]
/*----- Value in opt.h for ${definition.name}: !NO_SYS -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_HAVE_LOOPIF") && (definition.value != "valueNotSetted") && (definition.value != lwip_netif_loopback)]
/*----- Value in opt.h for ${definition.name}: LWIP_NETIF_LOOPBACK -----*/
#define ${definition.name}  ${definition.value}
            [/#if]           
            [#if (definition.name=="PPPOL2TP_AUTH_SUPPORT") && (definition.value != "valueNotSetted") && (definition.value != pppol2tp_support)]
/*----- Value in opt.h for ${definition.name}: PPPOL2TP_SUPPORT -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="PPPOS_SUPPORT") && (definition.value != "valueNotSetted") && (definition.value != ppp_support)]
/*----- Value in opt.h for ${definition.name}: PPP_SUPPORT -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_PPP_API") && (definition.value != "valueNotSetted") && (definition.value == "0") && (ppp_support == "1") && (lwip_rtos == 1)] [#-- Parameters with default value changing on certain condition --]
/*----- Value in opt.h for ${definition.name}: (PPP_SUPPORT && !NO_SYS) -----*/
#define ${definition.name}  ${definition.value}
            [/#if]             
            [#if (definition.name=="PPP_IPV4_SUPPORT") && (definition.value != "valueNotSetted") && (definition.value != lwip_ipv4)] [#-- Parameter with default value changing on certain condition --]
/*----- Value in opt.h for ${definition.name}: LWIP_IPV4 -----*/ 
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="PPP_IPV6_SUPPORT") && (definition.value != "valueNotSetted") && (definition.value != lwip_ipv6)] [#-- Parameter with default value changing on certain condition --]
/*----- Value in opt.h for ${definition.name}: LWIP_IPV6 -----*/ 
#define ${definition.name}  ${definition.value}
            [/#if]            
            [#if (definition.name=="PPP_MD5_RANDM") && (definition.value != "valueNotSetted") && (definition.value == "0") && ((chap_support == "1") || (eap_support == "1") || (pppol2tp_auth_support == "1"))]
/*----- Value in opt.h for ${definition.name}: (CHAP_SUPPORT || EAP_SUPPORT || PPPOL2TP_AUTH_SUPPORT) -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_ICMP6") && (definition.value != "valueNotSetted") && (definition.value != lwip_ipv6)]
/*----- Value in opt.h for ${definition.name}: LWIP_IPV6 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_IPV6_MLD") && (definition.value != "valueNotSetted") && (definition.value != lwip_ipv6)]
/*----- Value in opt.h for ${definition.name}: LWIP_IPV6 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_IPV6_REASS") && (definition.value != "valueNotSetted") && (definition.value != lwip_ipv6)]
/*----- Value in opt.h for ${definition.name}: LWIP_IPV6 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_ND6_QUEUEING") && (definition.value != "valueNotSetted") && (definition.value != lwip_ipv6)]
/*----- Value in opt.h for ${definition.name}: LWIP_IPV6 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_IPV6_AUTOCONFIG") && (definition.value != "valueNotSetted") && (definition.value != lwip_ipv6)]
/*----- Value in opt.h for ${definition.name}: LWIP_IPV6 -----*/
#define ${definition.name}  ${definition.value}
            [/#if] 
            [#if (definition.name=="TCPIP_THREAD_STACKSIZE") && (definition.value != "valueNotSetted") && (lwip_rtos == 1) && (definition.value != "0")]
/*----- Value in opt.h for ${definition.name}: 0 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="TCPIP_THREAD_PRIO")  && (definition.value != "valueNotSetted") && (definition.value != "1") && (lwip_rtos == 1)]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]                 
            [#if (definition.name=="SLIPIF_THREAD_STACKSIZE") && (definition.value != "valueNotSetted") && (lwip_rtos == 1) && (definition.value != "0")] [#-- Parameter with default value changing on certain condition --]
/*----- Value in opt.h for ${definition.name}: 0 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="SLIPIF_THREAD_PRIO") && (definition.value != "valueNotSetted") && (lwip_rtos == 1) && (definition.value != "1")] [#-- Parameter with default value changing on certain condition --]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="DEFAULT_THREAD_STACKSIZE") && (definition.value != "valueNotSetted") && (lwip_rtos == 1) && (definition.value != "0")]
/*----- Value in opt.h for ${definition.name}: 0 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]             
            [#if (definition.name=="DEFAULT_THREAD_PRIO") && (definition.value != "valueNotSetted") && (lwip_rtos == 1) && (definition.value != "1")] [#-- Parameter with default value changing on certain condition --]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_SOCKET_SET_ERRNO") && (definition.value != "valueNotSetted") && (lwip_rtos == 1) && (definition.value != "1")] [#-- Parameter with default value changing on certain condition --]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_POSIX_SOCKETS_IO_NAMES") && (definition.value != "valueNotSetted") && (lwip_rtos == 1) && (definition.value != "1")] [#-- Parameter with default value changing on certain condition --]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_COMPAT_SOCKETS") && (definition.value != "valueNotSetted") && (lwip_rtos == 1) && (definition.value != "1")] [#-- Parameter with default value changing on certain condition --]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="LWIP_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0")] [#-- Case1: Parameter with default value in MX different than in opt.h--]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if lwip_stats == "1"] [#-- Parameters with default value changing on certain condition --]
                [#if (definition.name=="LINK_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 0 or 1 -*/
#define ${definition.name}   ${definition.value}
                [/#if]
                [#if (definition.name=="ETHARP_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && (lwip_arp == "1")]
/*----- Value in opt.h for ${definition.name}: 0 or LWIP_ARP -----*/
#define ${definition.name}  ${definition.value}
                [/#if]
                [#if (definition.name=="IP_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 0 or 1 -----*/
#define ${definition.name}  ${definition.value}
                [/#if]
                [#if (definition.name=="IPFRAG_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && ((ip_reassembly == "1") || (ip_frag == "1"))]
/*----- Value in opt.h for ${definition.name}: 0 or (IP_REASSEMBLY || IP_FRAG) -*/
#define ${definition.name}  ${definition.value}
                [/#if]
                [#if (definition.name=="ICMP_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && (lwip_icmp == "1")]
/*----- Value in opt.h for ${definition.name}: 0 or LWIP_ICMP -----*/
#define ${definition.name}   ${definition.value}
                [/#if]
                [#if (definition.name=="IGMP_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && (lwip_igmp == "1")]
/*----- Value in opt.h for ${definition.name}: 0 or LWIP_IGMP -----*/
#define ${definition.name}   ${definition.value}
                [/#if]
                [#if (definition.name=="UDP_STATS") && (definition.value != "valueNotSetted")&& (definition.value == "0") && (lwip_udp == "1")]
/*----- Value in opt.h for ${definition.name}: 0 or LWIP_UDP -----*/
#define ${definition.name}  ${definition.value}
                [/#if]
                [#if (definition.name=="TCP_STATS")  && (definition.value != "valueNotSetted") && (definition.value == "0") && (lwip_tcp == "1")]
/*----- Value in opt.h for ${definition.name}: 0 or LWIP_TCP -----*/
#define ${definition.name}  ${definition.value}
                [/#if]
                [#if (definition.name=="MEM_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && (mem_libc_malloc == "0") && (mem_use_pools == "0")]
/*----- Value in opt.h for ${definition.name}: 0 or (!MEM_LIBC_MALLOC && !MEM_USE_POOLS) -*/
#define ${definition.name}   ${definition.value}
                [/#if]
                [#if (definition.name=="MEMP_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && (memp_mem_malloc == "0")]
/*----- Value in opt.h for ${definition.name}: 0 or !MEMP_MEM_MALLOC -*/
#define ${definition.name}   ${definition.value}
                [/#if]
                [#if (definition.name=="SYS_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && (lwip_rtos == 1)]
/*----- Value in opt.h for ${definition.name}: 0 or !NO_SYS -----*/
#define ${definition.name}  ${definition.value}
                [/#if]
                [#if (definition.name=="IP6_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && (lwip_ipv6 == "1")]
/*----- Value in opt.h for ${definition.name}: 0 or LWIP_IPV6 -----*/
#define ${definition.name}   ${definition.value}
                [/#if]
                [#if (definition.name=="ICMP6_STATS") && (definition.value != "valueNotSetted")  && (definition.value == "0") && (lwip_ipv6 == "1") && (lwip_icmp6 == "1")]
/*----- Value in opt.h for ${definition.name}: 0 or (LWIP_IPV6 && LWIP_ICMP6) -----*/
#define ${definition.name}  ${definition.value}
                [/#if]
                [#if (definition.name=="IP6_FRAG_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && ((lwip_ipv6 == "1") && ((lwip_ipv6_reass == "1") || (lwip_ipv6_frag == "1")))]
/*----- Value in opt.h for ${definition.name}: 0 or (LWIP_IPV6_FRAG || LWIP_IPV6_REASS) -*/
#define ${definition.name}  ${definition.value}
                [/#if]
                [#if (definition.name=="MLD6_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && (lwip_ipv6 == "1") && (lwip_ipv6_mld == "1")]
/*----- Value in opt.h for ${definition.name}: 0 or (LWIP_IPV6 && LWIP_IPV6_MLD) -----*/
#define ${definition.name}  ${definition.value}
                [/#if]
                [#if (definition.name=="ND6_STATS") && (definition.value != "valueNotSetted") && (definition.value == "0") && (lwip_ipv6 == "1")]
/*----- Value in opt.h for ${definition.name}: 0 or LWIP_IPV6 -----*/
#define ${definition.name}  ${definition.value}
                [/#if]
            [/#if] [#-- End STAT* parameters --] 
            [#if (definition.name=="CHECKSUM_GEN_IP") && (definition.value != "valueNotSetted") && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="CHECKSUM_GEN_UDP") && (definition.value != "valueNotSetted")  && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="CHECKSUM_GEN_TCP") && (definition.value != "valueNotSetted") && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="CHECKSUM_GEN_ICMP") && (definition.value != "valueNotSetted")&& (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="CHECKSUM_GEN_ICMP6") && (definition.value != "valueNotSetted") && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="CHECKSUM_CHECK_IP") && (definition.value != "valueNotSetted") && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="CHECKSUM_CHECK_UDP") && (definition.value != "valueNotSetted") && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}   ${definition.value}
            [/#if]
            [#if (definition.name=="CHECKSUM_CHECK_TCP") && (definition.value != "valueNotSetted") && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}  ${definition.value}
            [/#if]
            [#if (definition.name=="CHECKSUM_CHECK_ICMP") && (definition.value != "valueNotSetted")  && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}   ${definition.value}
            [/#if]
            [#if (definition.name=="CHECKSUM_CHECK_ICMP6") && (definition.value != "valueNotSetted") && (definition.value == "0")]
/*----- Value in opt.h for ${definition.name}: 1 -----*/
#define ${definition.name}   ${definition.value}
            [/#if]      
		[/#if] [#-- definition.defaultValue --]
	[/#list] [#-- SWIP.defines line 108 --]
/*-----------------------------------------------------------------------------*/
[/#compress]	
[/#if] [#-- SWIP.defines?? --]
[/#list] [#-- SWIPdatas --]
/* Parameter(s) not set in STM32CubeMX LwIP Configuration GUI -*/
/* LwIP Parameter(s) not in opt.h -----------------------------*/
#define LWIP_PROVIDE_ERRNO  1

/* USER CODE BEGIN 1 */

/* USER CODE END 1 */

#ifdef __cplusplus
}
#endif
#endif /*__${inclusion_protection}_H */

/************************* (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
