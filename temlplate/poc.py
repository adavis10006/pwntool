from pwn import *
import pwnlib.libcdb as libcdb
import sys
sys.path.append("/script/libformatstr")
from libformatstr import *
#
# ------------------------------------------------
#
ELF_PATH = ''
elf = ELF(ELF_PATH)
context.binary = ELF_PATH
#
# ------------------------------------------------
#
HOST = "172.18.0.2"
PORT = ""
LOCAL = 0 and True

def create_connection():
  if LOCAL:
    return process(ELF_PATH)
  else:
    return remote(HOST, PORT)
#
# ------------------------------------------------
#
USE_LIBC = False
if USE_LIBC:
  # LIBC_MD5 = '02ad2eb11b76c81da7fc43ffe958c14f'
  if LOCAL:
    LIBC_PATH = '/lib/x86_64-linux-gnu/libc.so.6'
    # system_offset = 0x45390
  elif LIBC_MD5:
    LIBC_PATH = libcdb.search_by_md5(LIBC_MD5)
    if (LIBC_PATH == None):
      log.error("libc can not find in pwntools libcdb.")
  else:
    LIBC_PATH = 'libc-2.19.so'
    # system_offset = 0x46590

  libc = ELF(LIBC_PATH)
#
# ------------------------------------------------
#
DUMP_INIT = False
def dump(p):
  global DUMP_INIT
  if not DUMP_INIT:
    DUMP_INIT = True

    with open("input", "w") as w:
      w.write(p)
  else:
    with open("input", "a") as w:
      w.write(p)
#
# ------------------------------------------------
#
FORK_BASE = 0 and True

def get_shell():
  global FORK_BASE
  shellcode = ''
  if FORK_BASE:
    if context.arch == 'i386':
      shellcode = asm(shellcraft.i386.linux.findpeersh())
    elif context.arch == 'amd64':
      shellcode = asm(shellcraft.amd64.linux.findpeersh())
    else:
      raise TypeError
  else:
    if context.arch == 'i386':
      shellcode = asm(shellcraft.i386.linux.sh())
    elif context.arch == 'amd64':
      shellcode = asm(shellcraft.amd64.linux.sh())
    else:
      raise TypeError

  return shellcode
#
# ------------------------------------------------
#
def dump_info():
  global ELF_PATH
  global FORK_BASE
  global LOCAL
  global HOST
  global PORT
  global USE_LIBC

  str = "\t" + "Binary: " + ELF_PATH + '\n'
  str += "\t  - " + "Type: " + ("fork-based" if FORK_BASE else "socat-based") + '\n'
  str += "\t  - " + "Arch: " + context.arch + '\n'
  str += "\t" + "Remote: " + ("True" if not LOCAL else "False") + '\n'
  if not LOCAL:
    str += "\t  - " + "host: " + HOST + '\n'
    str += "\t  - " + "port: " + PORT + '\n'
  if USE_LIBC:
    str += "\t" + "ROP problem need libc." + '\n'

  log.info(str)

#
# ------------------------------------------------
#
if __name__ == "__main__":
  dump_info()

  r = create_connection()

  r.interactive()
