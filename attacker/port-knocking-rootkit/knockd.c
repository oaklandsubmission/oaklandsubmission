// A netfilter kernel module to intercept TCP packets
// Parts of the code are adapted from https://github.com/gkelly
#include <linux/module.h>
#include <linux/printk.h>
#include <linux/sched.h>


#include <linux/tcp.h>
#include <linux/ip.h>
#include <linux/netfilter.h>
#include <linux/netfilter_ipv4.h>
#include <linux/skbuff.h>

MODULE_LICENSE("MIT");
MODULE_DESCRIPTION("A netfilter kernel module that open a port upon receiving a specific port knocking sequence");

#define DEBUGGER_NAME "gdb"
#define KNOCKD_MAX_SEQUENCE_LENGTH 10
#define KNOCKD_INFO KERN_INFO "knockd: "


static unsigned short int knockd_protected_port = 9090;
static int knockd_timeout = 10 * HZ;
static int knockd_sequence[KNOCKD_MAX_SEQUENCE_LENGTH] = {1234, 4321, 4444, 0}; // can be customized to either TCP seq or port seq
static int knockd_sequence_length = KNOCKD_MAX_SEQUENCE_LENGTH;

static int knockd_open = false;
static int knockd_sequence_index = 0;
static unsigned long knockd_sequence_timestamp = 0;
static struct nf_hook_ops knockd_netfilter_hook;

static void knockd_reset(void)
{
  knockd_open = false;
  knockd_sequence_index = 0;
  knockd_sequence_timestamp = 0;
}

static unsigned int knockd_filter_function(void *priv, struct sk_buff *skb,
                                           const struct nf_hook_state *state){

  struct iphdr *ip_header;
  struct tcphdr *tcp_header;
  ip_header = ip_hdr(skb);

  // see: https://stackoverflow.com/questions/16528868/c-linux-kernel-module-tcp-header
  tcp_header= (struct tcphdr *)((__u32 *)ip_header+ ip_header->ihl);

  unsigned int dst_port;
  dst_port = htons((unsigned short int)tcp_header->dest);

  // guard the protected port
  if (dst_port == knockd_protected_port) {
    printk(KNOCKD_INFO "checking for access to port %d ...\n", knockd_protected_port);
    if (knockd_open) {
      printk(KNOCKD_INFO "accepting connection to port %d \n", knockd_protected_port);
      return NF_ACCEPT;
    }
    printk(KNOCKD_INFO "port %d is not open\n", knockd_protected_port);
    return NF_DROP;
  } else { // listens for port knocking sequence
    if ((jiffies - knockd_sequence_timestamp) > knockd_timeout) { // reset the received sequence so far on timeout
      //printk(KNOCKD_INFO "knocking resets");
      knockd_reset();
    }
    if (tcp_header->dest == htons(knockd_sequence[knockd_sequence_index])) { // update the received sequence so far on a correct port knock
      printk(KNOCKD_INFO "knocking sequence %d on port %d received \n", knockd_sequence_index, knockd_sequence[knockd_sequence_index]);
      knockd_sequence_timestamp = jiffies;
      knockd_sequence_index++;
      if (knockd_sequence[knockd_sequence_index] == 0) {
        printk(KNOCKD_INFO "knocking completes");
        knockd_open = true;
        printk(KNOCKD_INFO "protected port %d has been openned", knockd_protected_port);
      }
    }
  }

  return NF_ACCEPT;
}


static int jump_to_invalid_addr(void){
  char* label_address = 0;
  asm volatile (
                "jmp unaligned\n"
                ".short 0xe8\n"
                "unaligned:");
  label_address = (char*)&&return_here;

  asm volatile(
               "push %0\n"
               "ret\n"
               ".string \"\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f\""
               :
               : "g" (label_address)
               );

 return_here:
  return -1;

  return 0;
}

static int detect_debugger(void){
  struct task_struct *task;
  for_each_process(task){
    pr_info("%s [%d]\n", task->comm, task->pid);
    if (strncmp(task->comm, DEBUGGER_NAME, 3) == 0){
      return 1;
    }
  }
  return 0;
}

static int __init knockd_init(void)
{

  if (detect_debugger() == 1){
    jump_to_invalid_addr();
    return -1;
  }

  //printk(KNOCKD_INFO "initing knocking sequence\n");
  knockd_reset();
  knockd_sequence[knockd_sequence_length] = 0;

  //printk(KNOCKD_INFO "initing netfilter hook function\n");
  knockd_netfilter_hook.hook = knockd_filter_function;
  knockd_netfilter_hook.hooknum = NF_INET_PRE_ROUTING;
  knockd_netfilter_hook.pf = PF_INET;
  knockd_netfilter_hook.priority = NF_IP_PRI_FIRST;
  nf_register_hook(&knockd_netfilter_hook);

  //printk(KNOCKD_INFO "done init\n");
  //printk(KNOCKD_INFO "listening for the port knocking sequence\n");

  return 0;
}

static void __exit knockd_exit(void)
{
  nf_unregister_hook(&knockd_netfilter_hook);
  //printk(KNOCKD_INFO "exit\n");
}

module_init(knockd_init);
module_exit(knockd_exit);
