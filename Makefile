include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-file_transfer
PKG_VERSION=1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-file_transfer
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=file transfer
	PKGARCH:=all
endef

define Package/luci-app-file_transfer/description
	This package contains LuCI configuration pages for file transfer.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-file_transfer/install
	$(INSTALL_DIR) $(1)/www/luci-static/resources/file_transfer
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/file_transfer
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/file_transfer
	
	$(INSTALL_DATA) ./usr/lib/lua/luci/controller/file_transfer/file_transfer.lua $(1)/usr/lib/lua/luci/controller/file_transfer/file_transfer.lua
	$(INSTALL_DATA) ./usr/lib/lua/luci/view/file_transfer/file_transfer.htm $(1)/usr/lib/lua/luci/view/file_transfer/file_transfer.htm
	$(INSTALL_DATA) ./www/luci-static/resources/file_transfer/* $(1)/www/luci-static/resources/file_transfer/
endef

$(eval $(call BuildPackage,luci-app-file_transfer))
