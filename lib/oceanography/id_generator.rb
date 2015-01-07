# Base64 implmentation of sequentail UUIDS
#
# 10⁻¹⁵ is the uncorrectable bit error rate of a typical hard disk.
# so this is our acceptable collision probability.
#
# The collinsion approximation function (Birthday problem)
# gives us the required key lengths by m ≃ N²/2p
# where m is value space, N number of hashed values and
# p the collision probability.
#
# Using the same sequential value space as CouchDB (16777216)
# and 10¹⁰ possible keys with 10⁻¹⁵ colission probalility we get
# random value space = (10¹⁰/16777216)²/(2*10⁻¹⁵) = 1.78E+22
# which can be represented by 13 base 64 digits.
#
# The sequential valuespace needs 5 base 64 digits, sinice 16777216(10) = BAAAA(64)
#
# As SHA1 is ~ uniformly distributed the solution here is to generate
# a SHA1 and truncate it.
# for url compatability we use use '-' and '_' instead of
# '+' and '/'. We also chop the '=' padding.
#
# Example key:

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
            .rjust(5, BASE_64_CHARS[0])
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
      .slice(0, 13)
    end

    def generateId()
      if @seq >= SEQUENTIAL_VALUE_SPACE
        initialize()
      end
      @seq += 1
      "#{@file_id}-#{base10toBase64(@seq)}"
    end
  end
end
