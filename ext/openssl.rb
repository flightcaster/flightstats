module OpenSSL
module SSL
remove_const :VERIFY_PEER
end
end
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
