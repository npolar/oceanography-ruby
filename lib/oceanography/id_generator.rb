# This generates sequential ids for point from netcdf files.
#
# 10⁻¹⁵ is the uncorrectable bit error rate of a typical hard disk.
# so this is our acceptable collision probability.
#
# Given that we don't hash more than 1 000 000 netCDF files
# the collinsion approximation function (Birthday problem)
# gives us the required value space by by m ≃ N²/2p
# where m i value space, N number of hased files and p the collision
# probability.
# m ≃ 1000000²/2*10⁻¹⁵ = 5E26
# so we need to be able to represent 5E26 values.
# For shorening the sting id length we use base 64 instead of hex, so
# 64^l > 5E26 => l > 14,8
# As SHA1 is ~ uniformly distributed the solution here is to generate
# a SHA1 and truncate it.
# for url compatability we use use '-' and '_' instead of
# '+' and '/'. We also chop the '=' padding.
#
# The netcdf id is appended by a sequentail number.
# Applying the same logic as above, limiting ourself to
# 1 000 000 points

module Oceanography
  class IdGenerator

    def initialize(seed)
      @file_id = Digest::SHA1.base64digest(seed.to_s)
        .gsub("+","-").gsub("/","_").gsub("=","")
        .slice(0, 15)
      @seq = -1
    end

    def generateId()
      @seq += 1
      "#{@file_id}-#{@seq}"
    end
  end
end
