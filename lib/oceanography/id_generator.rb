# Base64 implmentation of sequentail UUIDS
#
# 10⁻¹⁵ is the uncorrectable bit error rate of a typical hard disk.
# so this is our acceptable collision probability.
#
# CouchDbs sequentail ids have a 26 char hex random followed by
# a 6 hex char sequential. 26 chars => 16^26 = 2*10^31 hash space.
#
# The collinsion approximation function (Birthday problem)
# gives us the number of safe hashes out of the total hash space
# with a given collition probalitity by m ≃ N²/2p
# where m is value space, N number of hashed values and
# p the collision probability.
#
# So CouchDB safe randoms are N = (2mp)^(1/2) = (2*2*10^31*10^-15)
# N = 2*10^8
#
# The sequentail values are max 16^6 = 16777216 resulting in a
# best case safe max of 2*10^8*16^6 = 3,36*10^15
# Since CouchDB handles sequential overflow internally we can assume
# that this is also the worst case.
#
# For referance MD5 is 8.2×10^11 and SHA1 5.4*10^16
#
# So 3,36*10^15 is our target safe max.
#
# Just switching to base64 instead of hex would give us a random
# key length of ln(2*10^31)/ln(64) = 18 base64 chars.
# And the sequential part would need 4 base64 chars.
#
# So from 32 chars to 22, not bad.
#
# Our random part is generated each time we make a new instance of this
# class as well as when the sequentail part overflows.
# To get the most out of every random hash we should
# decrease the sequentail part, making it more probable that we
# fill that space entierly (improving our worst case).
# 3 base64 char gives us 64^3 = 262144
#
# That gives us best case: 2*10^8*64^3 = 5*10^13
#
# Reducing the random part to 16 chars would result in a vaule space
# of 8*10^28 with 1,27*10^7 safe hashes.
#
# That gives us best case: 1,27*10^7*64^3 = 3,32*10^12
# which is better than MD5.
# Worst case is usage dependent, but with bulk parsing we are close
# to best case.
#
# As SHA1 is ~ uniformly distributed the solution here is to generate
# a SHA1 and truncate it.
# for url compatability we use use '-' and '_' instead of
# '+' and '/'. We also chop the '=' padding.
#
# Example key: LdFN6V3tQsS_FpllAAAA

module Oceanography
  class IdGenerator

    SEQUENTIAL_VALUE_SPACE = 16777216
    BASE_64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

    def base10toBase64(number)
      num = number
      base64num = ""
      while (true) do
        if (num < 64)
          return base64num.prepend(BASE_64_CHARS[num])
            .rjust(4, BASE_64_CHARS[0])
        end

        reminder = num % 64
        base64num = base64num.prepend(BASE_64_CHARS[reminder])
        num = num / 64
      end
    end

    def initialize()
      @random = generateRandom()
      @seq = -1
    end

    def generateRandom()
      @file_id = Digest::SHA1.base64digest(SecureRandom.uuid)
      .gsub("+","-").gsub("/","_").gsub("=","")
      .slice(0, 16)
    end

    def generateId()
      if @seq >= SEQUENTIAL_VALUE_SPACE
        initialize()
      end
      @seq += 1
      "#{@file_id}#{base10toBase64(@seq)}"
    end
  end
end
